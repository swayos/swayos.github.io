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


# format disk with uefi or mbt partition schema

# mount disk

# pacstrap packages

#pacstrap -C pacman.conf /mnt base linux linux-firmware sudo git zsh zsh-autosuggestions iwd bluez bluez-utils blueman pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-media-session xdg-desktop-portal-wlr xorg-xwayland wayland-protocols sway swayidle swaylock grim slurp waybar wofi brightnessctl foot nautilus libreoffice-fresh gnome-system-monitor system-config-printer feh cups ttf-ubuntu-font-family terminus-font polkit-gnome wl-clipboard openbsd-netcat unzip meson pavucontrol scdoc

# copy aur packages under target/home/#$user/swayos

# copy fonts under target/usr/share/fonts

# copy home directory stuff under target/home/$user/

# chroot into new root

# start services

# install aur packages

# change shell to zsh

# cleanup
