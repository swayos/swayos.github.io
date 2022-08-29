#!/bin/bash
#
# This script installs the base image and finishes setup
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

# popup timezone selector, default is UTC

timefolder="/usr/share/zoneinfo"
timezone="/usr/share/zoneinfo/UTC"
while true; do
    layoutlist=$(ls $timefolder | nl)
    layout=$(dialog --stdout --backtitle "SwayOS Install" --menu "Select time zone" 0 50 10 ${layoutlist})
    if [ "$?" == 0 ]; then
	array=($layoutlist)
	index=$(($layout * 2 - 1))
	timezone=/usr/share/zoneinfo/${array[$index]}
	if [[ -d $timezone ]]; then
	    timefolder=$timezone
	else
	    break
	fi
    else
	timefolder="/usr/share/zoneinfo"
    fi
done

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

# notify about password

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

check "$?" "mount"

# dd swayos image to target disk

gunzip -c swayos.img.gz | dd of="${part_root}" bs=1M status=progress

# extend partition

e2fsck -f -y "${part_root}"
resize2fs "${part_root}"

# mount target disk

mount "${part_root}" /mnt

if [ -d "/sys/firmware/efi" ]; then
    mkdir -p /mnt/boot/efi
    mount "${part_boot}" /mnt/boot/efi
fi

# gen fstab

log "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab
check "$?" "genfstab"

# setup grub

log "Setting up grub"

if [ -d "/sys/firmware/efi" ]; then
    arch-chroot /mnt grub-install --efi-directory=/boot/efi --target=x86_64-efi --bootloader-id=GRUB
else
    arch-chroot /mnt grub-install --target=i386-pc $device
fi

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

check "$?" "grub-install"

# setup users

log "Adding user $username"

arch-chroot /mnt useradd -mU -s /usr/bin/zsh -G wheel,video $username
arch-chroot /mnt chsh -s /usr/bin/zsh
echo "$username ALL=(ALL) ALL" >> /mnt/etc/sudoers

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

arch-chroot /mnt ln -sf $timezone /etc/localtime

# set hw clock

arch-chroot /mnt hwclock --systohc

# set hostname

echo "${username}-pc" > /mnt/etc/hostname

# setup hosts file

cp /etc/hosts /mnt/etc/
echo "127.0.1.1 ${username}-pc" >> /mnt/etc/hosts

# setup iwd config to handle dhcp

mkdir -p /mnt/etc/iwd
cp /etc/iwd/main.conf /mnt/etc/iwd/

# copy home directory stuff under target/home/$user/

log "Copying configuration files"
cp -f -R /mnt/home/configs/. /mnt/home/$username
check "$?" "cp"
rm -r /mnt/home/configs
check "$?" "rm"

# add ethernet device to systemd.networkd

NETCONF=/mnt/etc/systemd/network/20-wired.network
printf "[Match]\nName=en*\nName=eth*\n[Network]\nDHCP=yes\nIPv6PrivacyExtensions=yes\n" | sudo tee "$NETCONF" > /dev/null

log "Starting services"

# initramfs

arch-chroot /mnt mkinitcpio -P

# start services

arch-chroot /mnt systemctl enable systemd-networkd
arch-chroot /mnt systemctl enable systemd-resolved
arch-chroot /mnt systemctl enable iwd
arch-chroot /mnt systemctl enable bluetooth
arch-chroot /mnt systemctl enable cups
check "$?" "systemctl enable"

# post-install

log "Chown files"

arch-chroot /mnt chown --recursive "$username:$username" /home/$username

log "Rebuild font cache"

arch-chroot /mnt fc-cache -fv

log "Trigger pacman update, it helps pamac to start up"

arch-chroot /mnt pacman -Sy

# cleanup

log "Cleaning up"

cp swayos_setup_log /mnt/home/$username
cp swayos_setup_out /mnt/home/$username
cp swayos_setup_err /mnt/home/$username
cp swayos_setup_ver /mnt/home/$username

# notify and reboot

$(dialog --stdout --backtitle "SwayOS Install" --msgbox "Install complete, press enter to reboot" 8 50)
reboot
