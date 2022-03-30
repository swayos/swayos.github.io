#!/bin/bash
#
# This script installs a base arch linux and swayos extensions to a target partition
#

# Set up logging
exec 1> >(tee "swayos_setup_out")
exec 2> >(tee "swayos_setup_err")

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

$(dialog --stdout --backtitle "SwayOS Install" --msgbox "User password will be the same as the root password. Feel free to change it after install." 8 50)

# partition and format

if [ -d "/sys/firmware/efi" ]; then
       log "Creating UEFI partitions"
       parted --script "${device}" -- mklabel gpt \
	     mkpart EFI fat32 1Mib 301MiB \
	     set 1 esp on \
	     mkpart root ext4 301MiB 100%
else
       log "Creating BIOS partitions"
       parted --script "${device}" -- mklabel gpt \
	      mkpart bios 1Mib 2MiB \
	      set 1 bios_grub on \
	      mkpart root ext4 100Mib 100%
fi


check "$?" "parted"

log "Creating file system"

part_boot="$(ls ${device}* | grep -E "^${device}p?1$")"
part_root="$(ls ${device}* | grep -E "^${device}p?2$")"

log "Using partitons boot : $part_boot root : $part_root"

wipefs "${part_root}"
wipefs "${part_boot}"

# format uefi partition as FAT
if [ -d "/sys/firmware/efi" ]; then
    mkfs.vfat -F32 "${part_boot}"
fi

mkfs.ext4 "${part_root}"
mount "${part_root}" /mnt

if [ -d "/sys/firmware/efi" ]; then
mkdir /mnt/boot
mount "${part_boot}" /mnt/boot
fi

check "$?" "mount"

# pacstrap packages

log "Installing packages"

pacstrap -C iso-pacman.conf /mnt - < pac-offline

#pacstrap -C iso-pacman.conf /mnt base linux linux-firmware sudo git zsh zsh-autosuggestions iwd bluez bluez-utils blueman pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-media-session xdg-desktop-portal-wlr xorg-xwayland wayland-protocols sway swayidle swaylock grim slurp waybar wofi brightnessctl foot nautilus libreoffice-fresh gnome-system-monitor system-config-printer feh cups ttf-ubuntu-font-family terminus-font polkit-gnome wl-clipboard openbsd-netcat unzip meson pavucontrol scdoc grub gobject-introspection dbus-glib vte3 appstream-glib archlinux-appstream-data

check "$?" "pacstrap"

# gen fstab

log "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab
check "$?" "genfstab"

# setup grub

log "Setting up grub"

if [ -d "/sys/firmware/efi" ]; then
    arch-chroot grub-install --target=x86_64-efi --efi-directory=$part_boot --bootloader-id=GRUB
else
    arch-chroot /mnt grub-install --target=i386-pc $device
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
fi

check "$?" "grub-install"

# arch-chroot /mnt /bin/bash /mnt/tmp/iso-install-chroot.sh

log "Adding user $username"

arch-chroot /mnt useradd -mU -s /usr/bin/zsh -G wheel,video $username
arch-chroot /mnt chsh -s /usr/bin/zsh

# set passwords

log "Settings passwords"

echo "$username:$password" | chpasswd --root /mnt
echo "root:$password" | chpasswd --root /mnt

# set locale

log "Setting locale and passwrods"

echo "en_US.UTF-8 UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

# set time zone

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Budapest /etc/localtime

# set hw clock

arch-chroot /mnt hwclock --systohc

# set hostname

echo "${username}-pc" > /mnt/etc/hostname

# copy fonts under target/usr/share/fonts

log "Copying fonts"
cp -r font/*.* /mnt/usr/share/fonts/
check "$?" "cp"

# copy home directory stuff under target/home/$user/

log "Copying configuration files"
cp -f -R home/. "/mnt/home/$username"
check "$?" "cp"

# copy offline repo to new install

log "Copying offline repo"

cp -r repo "/mnt/home/${username}/"
cp iso-pacman.conf "/mnt/home/${username}/"

check "$?" "cp"

# install aur packages

log "Installing aur packages"

cat pac-aur | while read line 
do
log "Installing $line"
    rel_path=$(ls repo/$line/*.pkg.tar.zst)
    arch-chroot /mnt pacman --noconfirm --config "/home/$username/iso-pacman.conf" -U "/home/$username/$rel_path"
done

# rel_path=$(ls repo/google-chrome/*.pkg.tar.zst)
# arch-chroot /mnt pacman --noconfirm --config "/home/$username/iso-pacman.conf" -U "/home/$username/$rel_path"
# rel_path=$(ls repo/iwgtk/*.pkg.tar.zst)
# arch-chroot /mnt pacman --noconfirm --config "/home/$username/iso-pacman.conf" -U "/home/$username/$rel_path"
# yrel_path=$(ls repo/libpamac-aur/*.pkg.tar.zst)
# arch-chroot /mnt pacman --noconfirm --config "/home/$username/iso-pacman.conf" -U "/home/$username/$rel_path"
# rel_path=$(ls repo/nerd-fonts-terminus/*.pkg.tar.zst)
# arch-chroot /mnt pacman --noconfirm --config "/home/$username/iso-pacman.conf" -U "/home/$username/$rel_path"
# rel_path=$(ls repo/pamac-aur/*.pkg.tar.zst)
# arch-chroot /mnt pacman --noconfirm --config "/home/$username/iso-pacman.conf" -U "/home/$username/$rel_path"
# rel_path=$(ls repo/wdisplays/*.pkg.tar.zst)
# arch-chroot /mnt pacman --noconfirm --config "/home/$username/iso-pacman.conf" -U "/home/$username/$rel_path"
# rel_path=$(ls repo/wlogout/*.pkg.tar.zst)
# arch-chroot /mnt pacman --noconfirm --config "/home/$username/iso-pacman.conf" -U "/home/$username/$rel_path"
# rel_path=$(ls repo/wob/*.pkg.tar.zst)
# arch-chroot /mnt pacman --noconfirm --config "/home/$username/iso-pacman.conf" -U "/home/$username/$rel_path"
# arch-chroot /mnt pacman -U /tmp/sway-overview/*.pkg.tar.zst

# start services

log "Starting services"

#NETCONF=/etc/systemd/network/20-wired.network
#if [ ! -f "$NETCONF" ]; then
#    echo $'[Match]\nName=enp1s0\n[Network]\nDHCP=yes\n' | sudo tee "$NETCONF" > /dev/null
#fi

arch-chroot /mnt systemctl enable systemd-networkd
arch-chroot /mnt systemctl enable iwd
arch-chroot /mnt systemctl enable bluetooth
arch-chroot /mnt systemctl enable cups
check "$?" "systemctl enable"

# cleanup

cp swayos_setup_log /mnt/home/$username
cp swayos_setup_out /mnt/home/$username
cp swayos_setup_err /mnt/home/$username
rm -r /mnt/home/$username/repo

# notify and reboot

$(dialog --stdout --backtitle "SwayOS Install" --msgbox "Install complete, press enter to reboot" 8 50)
reboot
