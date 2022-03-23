#!/bin/bash

# popup keyboard map selector, default is us

layoutlist=$(localectl list-keymaps | sort | nl)
layout=$(dialog --stdout --backtitle "SwayOS Install" --menu "What is your keyboard layout?\nCancel to continue with US layout" 0 50 10 ${layoutlist})

if [ "$?" == 0 ]; then
    array=($layoutlist)
    index=$(($layout * 2 - 1))
    keymap=${array[$index]}
    echo "selected layout is $keymap, loading keys"
    #loadkeys $keymap
fi

# popup disk selector

devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
device=$(dialog --stdout --backtitle "SwayOS Install" --nocancel --menu "Select installation disk" 0 50 0 ${devicelist})

# popup entire disk will be formatted

$(dialog --stdout --backtitle "SwayOS Install" --yesno "All data will be lost on $device.\nAre you sure?" 8 50) || exit 1

# ask for root password

while true; do
    password=$(dialog --stdout --insecure --passwordbox "What will be your root password?" 8 50)
    password2=$(dialog --stdout --insecure --passwordbox "Enter password again just to be sure" 8 50)
    [ "$password" = "$password2" ] && break
    $(dialog --stdout --msgbox "Passwords mismatch" 8 50)
done

# ask for user

username = $(dialog --stdout --insecure --nocancel --inputbox "What will be your username?" 8 50)

# notify about passwrod

$(dialog --stdout --backtitle "SwayOS Install" --msgbox "User password will be the same as the root password. Feel free to change it after install." 8 50)man

# format for BIOS

echo "Creating partitions..."

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

echo "Creating file systems"

rootdev = "$device2"

if [ -d "$devicep2" ]; then
  rootdev = "$devicep2"
fi

mkfs.ext4 $rootdev

echo "Created ext4 on $rootdev"

# mount disk

echo "Mounting disk"

mount $rootdev /mnt

# pacstrap packages

echo "Installing packages"

pacstrap -C pacman.conf /mnt base linux linux-firmware sudo git zsh zsh-autosuggestions iwd bluez bluez-utils blueman pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-media-session xdg-desktop-portal-wlr xorg-xwayland wayland-protocols sway swayidle swaylock grim slurp waybar wofi brightnessctl foot nautilus libreoffice-fresh gnome-system-monitor system-config-printer feh cups ttf-ubuntu-font-family terminus-font polkit-gnome wl-clipboard openbsd-netcat unzip meson pavucontrol scdoc

# copy aur packages under target/home/#$user/swayos

cd repo/wob /mnt/tmp/wob
cd repo/wlogout /mnt/tmp/wlogout
cd repo/wdisplays /mnt/tmp/wdisplays
cd repo/iwgtk /mnt/tmp/iwgtk
cd repo/pamac-aur /mnt/tmp/pamac-aur
cd repo/google-chrome /mnt/tmp/google-chrome
cd repo/fonts-terminus /mnt/tmp/fonts-terminus
cd repo/sway-overview /mnt/tmp/sway-overview

# copy fonts under target/usr/share/fonts

cp -f font/*.* /mnt/usr/share/fonts/

# copy home directory stuff under target/home/$user/

cp -f -R home/. $("/mnt/home/$username")

# gen fstab

echo "generating fstab"

genfstab -U /mnt >> /mnt/etc/fstab

# chroot into new root

echo "chroot into /mnt"

arch-chroot /mnt

# start services

echo "starting services"

sudo systemctl enable systemd-networkd --now
sudo systemctl enable iwd --now
sudo systemctl enable bluetooth --now
sudo systemctl enable cups --now

# install aur packages

echo "Installing aur packages"

cd /tmp/wob
ls *.pkg.tar.zst | pacman -U
cd /tmp/wlogout
ls *.pkg.tar.zst | pacman -U
cd /tmp//wdisplays
ls *.pkg.tar.zst | pacman -U
cd /tmp/iwgtk
ls *.pkg.tar.zst | pacman -U
cd /tmp/pamac-aur
ls *.pkg.tar.zst | pacman -U
cd /tmp/google-chrome
ls *.pkg.tar.zst | pacman -U
cd /tmp/nerd-fonts-terminus
ls *.pkg.tar.zst | pacman -U
cd /tmp/sway-overview
meson build
ninja -C build
ninja -C build install

# change shell to zsh

echo "Changing shell"

chsh -s /bin/zsh

# cleanup
