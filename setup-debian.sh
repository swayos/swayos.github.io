#!/bin/bash
#
# This script installs SwayOS on a pre-installed debian linux
# A user with sudo permissions and a live network connection is needed
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

log "Refreshing package db"
sudo apt-get update -y
check "$?" "apt-get update"
sudo apt-get upgrade -y
check "$?" "apt-get upgrade"


log "Installing packages"
sudo apt-get install -y --no-install-recommends --no-install-suggests \
     git \
     zsh \
     zsh-autosuggestions \
     iwd \
     bluez \
     blueman \
     wireplumber \
     pipewire-pulse \
     pamixer \
     xdg-desktop-portal-wlr \
     xwayland \
     wayland-protocols \
     sway \
     swaybg \
     swayidle \
     swaylock \
     wdisplays \
     wob \
     grim \
     slurp \
     waybar \
     tofi \
     brightnessctl \
     foot \
     nautilus \
     gnome-system-monitor \
     system-config-printer \
     cups \
     xfonts-terminus \
     fonts-terminus-otb \
     lxsession \
     wl-clipboard \
     pavucontrol \
     nano \
     jq \
     meson \
     flatpak \
     gnome-software \
     gnome-software-plugin-flatpak \
     unzip \
     pkg-config \
     wayland-protocols \
     libwayland-dev \
     libfreetype-dev \
     libgtk-3-dev \
     libgtk-4-dev \
     libglew-dev \
     libqrencode-dev \
     scdoc \
     libsdl2-dev \
     libswscale-dev \
     libmupdf-dev \
     libmujs-dev \
     libopenjp2-7-dev \
     libgumbo-dev \
     libavutil-dev \
     libavcodec-dev \
     libavdevice-dev \
     libavformat-dev \
     libswscale-dev \
     libswresample-dev \
     libxkbcommon-dev \
     libjbig2dec0-dev


log "Cloning swayOS repo"
git clone https://github.com/rik1599/swayos.github.io.git
cd swayos.github.io

log "Copying settings to home folder"
cp -f -R home/. ~/
check "$?" "cp"


log "Starting services"
sudo systemctl enable iwd --now
sudo systemctl enable bluetooth --now
sudo systemctl enable cups --now


log "Installing iwgtk"
git clone https://github.com/J-Lentz/iwgtk
cd iwgtk
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..


log "Linking software store"
sudo ln /usr/bin/gnome-software /usr/bin/appstore


log "Linking zsh-autosuggestions"
sudo mkdir -p /usr/share/zsh/plugins/zsh-autosuggestions
sudo ln /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh


log "Linking polkit"
sudo mkdir -p /usr/lib/polkit-gnome
sudo ln /usr/bin/lxpolkit /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

log "Setup Flathub"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

log "Installing sov"
git clone https://github.com/milgra/sov
cd sov
meson build
ninja -C build
sudo ninja -C build install
cd ..


log "Install kuid"
git clone https://github.com/milgra/kuid
check "$?" "GIT KUID"
cd kuid
meson setup build --buildtype=release
check "$?" "BUILD KUID"
ninja -C build
check "$?" "BUILD KUID"
sudo ninja -C build install
check "$?" "INSTALL KUID"
cd ..
rm -rf kuid
log "sov installed"


log "Install wcp"
git clone https://github.com/milgra/wcp
check "$?" "GIT WCP"
cd wcp
mkdir ~/.config/wcp
cp wcp-debian.sh ~/.config/wcp/wcp.sh
cp -R res ~/.config/wcp/
cd ..


log "Install wfl"
git clone https://github.com/milgra/wfl
check "$?" "GIT WFL"
cd wfl
mkdir ~/.config/wfl
cp wfl.sh ~/.config/wfl/
cp -R res ~/.config/wfl/
cd ..


log "Installing vmp"
git clone https://github.com/milgra/vmp
cd vmp
meson build
ninja -C build
sudo ninja -C build install
cd ..


log "Installing mmfm"
git clone https://github.com/milgra/mmfm
cd mmfm
meson build
ninja -C build
sudo ninja -C build install
cd ..


log "Cleaning up"
cd ..
rm -f -R swayos.github.io
check "$?" "rm"


log "Changing shell to zsh"
chsh -s /bin/zsh
check "$?" "chsh"


log "Setup is done, please reboot the computer (type sudo reboot)"
