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
sudo apt-get install -y \
     git \
     zsh \
     zsh-autosuggestions \
     iwd \
     bluez \
     blueman \
     pipewire \
     pipewire-pulse \
     pipewire-audio-client-libraries \
     pipewire-bin \
     xdg-desktop-portal-wlr \
     xwayland \
     wayland-protocols \
     sway \
     swaybg \
     swayidle \
     swaylock \
     pamixer \
     wlogout \
     wdisplays \
     wob \
     grim \
     slurp \
     waybar \
     wofi \
     brightnessctl \
     foot \
     chromium \
     nautilus \
     libreoffice \
     gnome-system-monitor \
     system-config-printer \
     cups \
     xfonts-terminus \
     lxsession \
     wl-clipboard \
     pavucontrol \
     emacs-nox \
     meson \
     gnome-software \
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
git clone https://github.com/swayos/swayos.github.io.git
cd swayos.github.io
git switch dev

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


log "Installing sov"
git clone https://github.com/milgra/sov
cd sov
meson build
ninja -C build
sudo ninja -C build install
cd ..


log "Install wcp"
git clone https://github.com/milgra/wcp
check "$?" "GIT WCP"
cd wcp
git switch dev
mkdir ~/.config/wcp
cp wcp-void.sh ~/.config/wcp/wcp.sh
cp -R res ~/.config/wcp/
cd ..


log "Install wfl"
git clone https://github.com/milgra/wfl
check "$?" "GIT WFL"
cd wfl
git switch dev
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


log "Setup is done, please log out and log in back again ( type exit )"
