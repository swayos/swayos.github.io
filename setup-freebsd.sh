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


log "Installing env"
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
     octopkg \
     sdl2 \
     jbig2dec \
     drm-kmod \
     mupdf \
     mujs \
     gumbo

log "Adding user to seatd and video group"
sudo pw usermod $USER -G video
sudo sysrc seatd_enable=YES

log "Install ffmpeg 5"

sudo pkg install -y \
     gcc \
     devel/nasm \
     textproc/texi2html \
     graphics/frei0r \
     multimedia/v4l_compat \
     devel/gmake \
     devel/pkgconf \
     lang/perl5.32 \
     fdk-aac \
     multimedia/aom \
     multimedia/libass \
     multimedia/dav1d \
     graphics/libdrm \
     x11-fonts/fontconfig \
     print/freetype2 \
     math/gmp \
     security/gnutls \
     audio/lame \
     textproc/libxml2 \
     audio/opus \
     multimedia/svt-av1 \
     multimedia/libv4l \
     multimedia/libva \
     multimedia/libvdpau \
     multimedia/vmaf \
     audio/libvorbis \
     multimedia/libvpx \
     graphics/webp \
     multimedia/libx264 \
     multimedia/x265

log "Building FFMPEG 5.1.2"
wget https://ffmpeg.org/releases/ffmpeg-5.1.2.tar.gz
check "$?" "WGET FFMPEG"
tar -xvzf ffmpeg-5.1.2.tar.gz
check "$?" "TAR FFMPEG"
cd ffmpeg-5.1.2
./configure \
    --prefix=/usr \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --extra-libs=-lpthread \
    --extra-libs=-lm \
    --bindir="$HOME/bin" \
    --enable-gpl \
    --enable-libfdk_aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    --enable-shared
check "$?" "CONF FFMPEG"
gmake
check "$?" "MAKE FFMPEG"
sudo gmake install
check "$?" "ISNTALL FFMPEG"
cd ..
rm -rf ffmpeg-5.1.2
log "FFMPEG 5.1.2 installed"



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


log "Linking software store"
sudo ln /usr/local/bin/octopkg /usr/local/bin/appstore


log "Installing sov"
git clone https://github.com/milgra/sov
cd sov
LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib meson setup build --buildtype=release
LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib ninja -C build
sudo ninja -C build install
cd ..


log "Installing wcp"
git clone https://github.com/milgra/wcp
cd wcp
LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib meson setup build --buildtype=release
LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib ninja -C build
sudo ninja -C build install
cd ..


log "Installing vmp"
git clone https://github.com/milgra/vmp
cd vmp
LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib meson setup build --buildtype=release
LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib ninja -C build
sudo ninja -C build install
cd ..


log "Installing mmfm"
git clone https://github.com/milgra/mmfm
cd mmfm
LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib meson setup build --buildtype=release
LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib ninja -C build
sudo ninja -C build install
cd ..

sudo service seatd start

log "Cleaning up"
cd ..
rm -f -R swayos.github.io
check "$?" "rm"

log "Changing shell to zsh"
chsh -s /usr/local/bin/zsh
check "$?" "chsh"


log "Setup is done, please log out and log in back again ( type exit )"
