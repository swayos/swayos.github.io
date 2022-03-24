#!/bin/bash
#
# This script prepares the target disks and boots partitions and pacstraps offline packages to the target install,
# also copies aur packages and configs and starts the chroot script
#

log(){
    echo "*********** $1 ***********"
    now=$(date +"%T")
    echo "$now $1" >> ~/swayos_setup_log
}

check(){
    if [ "$1" != 0 ]; then
	echo "$2 error : $1" | tee -a ~/swayos_setup_log
	exit 1
    fi
}

# popup keyboard map selector, default is us

layoutlist=$(localectl list-keymaps | sort | nl)
layout=$(dialog --stdout --backtitle "SwayOS Install" --menu "What is your keyboard layout?\nCancel to continue with US layout" 0 50 10 ${layoutlist})

if [ "$?" == 0 ]; then
    array=($layoutlist)
    index=$(($layout * 2 - 1))
    keymap=${array[$index]}
    log "Loading keys $keympap"
    loadkeys $keymap
fi

log "Selected layout $layout"

# popup disk selector

devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
device=$(dialog --stdout --backtitle "SwayOS Install" --nocancel --menu "Select installation disk" 0 50 0 ${devicelist})
log "Selected target device $device"

# popup entire disk will be formatted

$(dialog --stdout --backtitle "SwayOS Install" --yesno "All data will be lost on $device.\nAre you sure?" 8 50) || exit 1

# ask for root password

while true; do
    password=$(dialog --stdout --insecure --passwordbox "What will be your root password?" 8 50)
    password2=$(dialog --stdout --insecure --passwordbox "Enter password again just to be sure" 8 50)
    [ "$password" = "$password2" ] && break
    $(dialog --stdout --msgbox "Passwords mismatch" 8 50)
done

log "Selected root password"

# ask for user

username = $(dialog --stdout --insecure --nocancel --inputbox "What will be your username?" 8 50)

log "Selected user $username"

# notify about passwrod

$(dialog --stdout --backtitle "SwayOS Install" --msgbox "User password will be the same as the root password. Feel free to change it after install." 8 50)man

# format for BIOS

log "Creating partitions"

umount /mnt

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${device}
  g # GPT
  n # new partition
  1 # partition number 1
    # default - start at beginning of disk 
  +100M # 100 MB boot parttion
  t # partition type
  4 # BIOS partition
  n # new partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

check "$?" "fdisk"

log "Creating file systems"

bootdev = "${device}1"
rootdev = "${device}2"

if [ -d "${device}p2" ]; then
    bootdev = "${device}p1"
    rootdev = "${device}p2"
fi

log "Using partitons boot : $bootdev root : $rootdev"
log "Creating ext4 file system on $rootdev"
mkfs.ext4 $rootdev
check "$?" "mkfs.ext4"

# mount disk

log "Mounting disk"
mount $rootdev /mnt
check "$?" "mount"

# pacstrap packages

log "Installing packages"
pacstrap -C iso-pacman.conf /mnt base linux linux-firmware sudo git zsh zsh-autosuggestions iwd bluez bluez-utils blueman pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-media-session xdg-desktop-portal-wlr xorg-xwayland wayland-protocols sway swayidle swaylock grim slurp waybar wofi brightnessctl foot nautilus libreoffice-fresh gnome-system-monitor system-config-printer feh cups ttf-ubuntu-font-family terminus-font polkit-gnome wl-clipboard openbsd-netcat unzip meson pavucontrol scdoc grub
check "$?" "pacstrap"

# copy aur packages under target/home/#$user/swayos

log "Copying aur packages"
cp -r repo/wob /mnt/tmp/wob
cp -r repo/wlogout /mnt/tmp/wlogout
cp -r repo/wdisplays /mnt/tmp/wdisplays
cp -r repo/iwgtk /mnt/tmp/iwgtk
cp -r repo/pamac-aur /mnt/tmp/pamac-aur
cp -r repo/google-chrome /mnt/tmp/google-chrome
cp -r repo/nerd-fonts-terminus /mnt/tmp/nerd-fonts-terminus
cp -r repo/sway-overview /mnt/tmp/sway-overview
check "$?" "cp"

# copy fonts under target/usr/share/fonts

log "Copying fonts"
cp -r font/*.* /mnt/usr/share/fonts/
check "$?" "cp"

# copy home directory stuff under target/home/$user/

log "Copying configuration files"
cp -f -R home/. "/mnt/home/$username"
check "$?" "cp"

# gen fstab

log "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab
check "$?" "genfstab"

# copy chroot install

cp -f iso-install-chroot.sh /mnt/tmp/

# run chroot install script

arch-chroot /mnt /bin/bash /mnt/tmp/iso-install-chroot.sh
