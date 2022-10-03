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


log "Installing git"
sudo apt-get -y install git


log "Cloning swayOS repo"
git clone https://github.com/swayos/swayos.github.io.git
cd swayos.github.io


log "Installing needed official packages"
xargs sudo apt-get install -y < pacs/debian/swayos
check "$?" "apt-get install pacs/debian/swayos"


log "Copying ttf fonts to font directory"
sudo cp -f font/*.* /usr/share/fonts/
check "$?" "cp"


log "Copying settings to home folder"
cp -f -R home/. ~/
check "$?" "cp"


log "Starting services"
sudo systemctl enable iwd --now
sudo systemctl enable bluetooth --now
sudo systemctl enable cups --now


log "Installing google chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb

log "Installing sov"
git clone https://github.com/milgra/sov
cd sov
meson build
ninja -C build
sudo ninja -C build install
cd ..

log "Installing iwgtk"
git clone https://github.com/J-Lentz/iwgtk
cd iwgtk
make
sudo make install
cd ..

log "Install Ly login manager"
sudo apt install build-essential libpam0g-dev libxcb-xkb-dev
git clone --recurse-submodules https://github.com/fairyglade/ly
cd ly
sudo make
sudo make install installsystemd
sudo systemctl enable ly.service --now
sudo systemctl disable getty@tty2.service --now

log "Linking software store"
sudo ln /usr/bin/gnome-software /usr/bin/pamac-manager

log "Linking zsh-autosuggestions"
sudo mkdir -p /usr/share/zsh/plugins/zsh-autosuggestions
sudo ln /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

log "Linking polkit"
sudo mkdir -p /usr/lib/polkit-gnome
sudo ln /usr/bin/lxpolkit /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

log "Cleaning up"
cd ..
rm -f -R swayos.github.io
check "$?" "rm"

log "Changing shell to zsh"
chsh -s /bin/zsh
check "$?" "chsh"


log "Setup is done, please log out and log in back again ( type exit )"
