#!/bin/bash
#
# This script installs SwayOS on a pre-installed FreeBSD
# Needed stuff:
# - sudo permissions for the current user
# - active internet connection
# - video driver
# - wget and bash
# On my machine it looks like this :

# sysrc wlans_iwm0="wlan0"
# sysrc ifconfig_wlan0="WPA DHCP"
# sysrc iwm7260fw_load="YES"
# vi /etc/wpa_supplicant.conf
# network={
# 	ssid="myssid"
# 	psk="mypsk"
# }

# pkg install sudo
# pw usermod milgra -G wheel
# visudo
# enable wheel

# pkg install wget bash

# pkg install drm-kmod
# sysrc kld_list="i915kms"
# pw usermod milgra -G video

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

log "Refreshing package db"
sudo pkg update
check "$?" "pkg update"
sudo pkg upgrade
check "$?" "pkg upgrade"


log "Installing git"
sudo pkg install -y \
     git \
     zsh \
     zsh-autosuggestions \
     pipewire \
     xdg-desktop-portal-wlr \
     xwayland \
     wlogout \
     wdisplays \
     wob \
     grim \
     slurp \
     waybar \
     wofi \
     foot \
     nautilus \
     libreoffice \
     gnome-system-monitor \
     system-config-printer \
     cups \
     lxsession \
     wl-clipboard \
     pavucontrol \
     pamixer \
     emacs-nox \
     adapta-gtk-theme \
     meson \
     pkgconf \
     cmake \
     wayland-protocols \
     seatd \
     chromium \
     meson \
     ninja \
     sway \
     swaybg \
     swayidle \
     swaylock \
     octopkg

log "Cloning swayOS repo"
git clone https://github.com/swayos/swayos.github.io.git
cd swayos.github.io


log "Copying ttf fonts to font directory"
sudo mkdir -p /usr/local/share/fonts/
sudo cp -f font/*.* /usr/local/share/fonts/
check "$?" "cp"


log "Copying settings to home folder"
cp -f -R home/. ~/
check "$?" "cp"


log "Starting services"

sudo sysrc seatd_enable=YES
service seatd start


log "Linking software store"
sudo ln /usr/local/bin/octopkg /usr/local/bin/appstore


log "Installing sov"
git clone https://github.com/milgra/sov
cd sov
meson build
ninja -C build
sudo ninja -C build install
cd ..


log "Cleaning up"
cd ..
rm -f -R swayos.github.io
check "$?" "rm"

log "Changing shell to zsh"
chsh -s /usr/local/bin/zsh
check "$?" "chsh"


log "Setup is done, please log out and log in back again ( type exit )"
