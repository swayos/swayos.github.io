#!/bin/bash
#
# This script prepares the target disks and boots partitions and pacstraps offline packages to the target install,
# also copies aur packages and configs and starts the chroot script
#

# Set up logging
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

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
    password=$(dialog --stdout --backtitle "SwayOS Install" --insecure --passwordbox "What will be your root password?" 8 50)
    password2=$(dialog --stdout --backtitle "SwayOS Install" --insecure --passwordbox "Enter password again just to be sure" 8 50)
    [ "$password" = "$password2" ] && break
    $(dialog --stdout --msgbox "Passwords mismatch" 8 50)
done

log "Selected root password"

# ask for user

username=$(dialog --stdout --backtitle "SwayOS Install" --nocancel --inputbox "What will be your username?" 8 50)

log "Selected user $username"

# notify about passwrod

$(dialog --stdout --backtitle "SwayOS Install" --msgbox "User password will be the same as the root password. Feel free to change it after install." 8 50)man

# format for BIOS

umount /mnt

### Setup the disk and partitions ###
swap_size=$(free --mebi | awk '/Mem:/ {print $2}')
swap_end=$(( $swap_size + 129 + 1 ))MiB

if [ -d "/sys/firmware/efi" ]; then
       log "Creating UEFI partitions, sway size $swap_size"
       parted --script "${device}" -- mklabel gpt \
	     mkpart EFI fat32 1Mib 301MiB \
	     set 1 esp on \
	     mkpart primary linux-swap 100MiB ${swap_end} \
	     mkpart primary ext4 ${swap_end} 100%
else
       log "Creating BIOS partitions, sway size $swap_size"
       parted --script "${device}" -- mklabel gpt \
	      mkpart primary ext4 1Mib 100MiB \
	      set 1 bios_grub on \
	      mkpart primary linux-swap 100MiB ${swap_end} \
	      mkpart primary ext4 ${swap_end} 100%
fi

check "$?" "parted"

log "Creating file systems"

# Simple globbing was not enough as on one device I needed to match /dev/mmcblk0p1
# but not /dev/mmcblk0boot1 while being able to match /dev/sda1 on other devices.
part_boot="$(ls ${device}* | grep -E "^${device}p?1$")"
part_swap="$(ls ${device}* | grep -E "^${device}p?2$")"
part_root="$(ls ${device}* | grep -E "^${device}p?3$")"

log "Using partitons boot : $part_boot root : $part_root"

wipefs "${part_root}"
wipefs "${part_boot}"

# format uefi partition as FAT
if [ -d "/sys/firmware/efi" ]; then
    mkfs.vfat -F32 "${part_boot}"
fi

mkswap "${part_swap}"
mkfs.ext4 -f "${part_root}"

swapon "${part_swap}"
mount "${part_root}" /mnt
mkdir /mnt/boot
mount "${part_boot}" /mnt/boot

check "$?" "mount"

# pacstrap packages

log "Installing packages"
pacstrap -C iso-pacman.conf /mnt base linux linux-firmware sudo git zsh zsh-autosuggestions iwd bluez bluez-utils blueman pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-media-session xdg-desktop-portal-wlr xorg-xwayland wayland-protocols sway swayidle swaylock grim slurp waybar wofi brightnessctl foot nautilus libreoffice-fresh gnome-system-monitor system-config-printer feh cups ttf-ubuntu-font-family terminus-font polkit-gnome wl-clipboard openbsd-netcat unzip meson pavucontrol scdoc grub
check "$?" "pacstrap"

# copy aur packages under target/home/#$user/swayos

log "Copying aur packages"
cp -r repo/wob "/mnt/home/$username"
cp -r repo/wlogout "/mnt/home/$username"
cp -r repo/wdisplays "/mnt/home/$username"
cp -r repo/iwgtk "/mnt/home/$username"
cp -r repo/pamac-aur "/mnt/home/$username"
cp -r repo/google-chrome "/mnt/home/$username"
cp -r repo/nerd-fonts-terminus "/mnt/home/$username"
cp -r repo/sway-overview "/mnt/home/$username"
check "$?" "cp"

# copy fonts under target/usr/share/fonts

log "Copying fonts"
cp -r font/*.* /mnt/usr/share/fonts/
check "$?" "cp"

# gen fstab

log "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab
check "$?" "genfstab"

# arch-chroot /mnt /bin/bash /mnt/tmp/iso-install-chroot.sh

log "Adding user $username"

arch-chroot /mnt useradd -mU -s /usr/bin/zsh -G wheel,video $username
arch-chroot /mnt chsh -s /usr/bin/zsh

# copy home directory stuff under target/home/$user/

log "Copying configuration files"
cp -f -R home/. "/mnt/home/$username"
check "$?" "cp"

# setup grub

log "Setup grub"

if [ -d "/sys/firmware/efi" ]; then
    arch-chroot grub-install --target=x86_64-efi --efi-directory=$part_boot --bootloader-id=GRUB
else
    arch-chroot /mnt grub-install --modules="ext4 part_gpt" --target=i386-pc $device
fi

check "$?" "grub-install"

# start services

log "starting services"
arch-chroot /mnt sudo systemctl enable systemd-networkd
arch-chroot /mnt sudo systemctl enable iwd
arch-chroot /mnt sudo systemctl enable bluetooth
arch-chroot /mnt sudo systemctl enable cups
check "$?" "systemctl enable"

# install aur packages

log "Installing aur packages"
arch-chroot /mnt pacman -d -U /tmp/wob/*.pkg.tar.zst
arch-chroot /mnt pacman -d -U /tmp/wlogout/*.pkg.tar.zst
arch-chroot /mnt pacman -d -U /tmp/wdisplays/*.pkg.tar.zst
arch-chroot /mnt pacman -d -U /tmp/iwgtk/*.pkg.tar.zst
arch-chroot /mnt pacman -d -U /tmp/pamac-aur/*.pkg.tar.zst
arch-chroot /mnt pacman -d -U /tmp/google-chrome/*.pkg.tar.zst
arch-chroot /mnt pacman -d -U /tmp/nerd-fonts-terminus/*.pkg.tar.zst
# arch-chroot /mnt pacman -U /tmp/sway-overview/*.pkg.tar.zst

# set locale

echo "LANG=en_GB.UTF-8" > /mnt/etc/locale.conf
echo "$username:$password" | chpasswd --root /mnt
echo "root:$password" | chpasswd --root /mnt

