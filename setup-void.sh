#!/bin/bash
#
# This script installs SwayOS on a pre-installed void linux
# A user with sudo permissions and a live network connection is needed
#
# default void install

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
sudo xbps-install -u xbps
sudo xbps-install -Su
check "$?" "package update"


log "Installing git"
sudo xbps-install --yes git


log "Cloning swayOS repo"
git clone https://github.com/swayos/swayos.github.io.git
cd swayos.github.io


log "Installing needed official packages"
cat pacs/void/swayos > pacs/online
sudo xbps-install --yes - < pacs/online
check "$?" "package download"


log "Copying terminus-ttf fonts to font directory"
sudo cp -f font/*.* /usr/share/fonts/
check "$?" "cp"


log "Copying settings to home folder"
cp -f -R home/. ~/
check "$?" "cp"


log "Adding user to needed groups"
usermod -a -G bluetooth milgra
usermod -a -G _seatd milgra


log "Create xdg runtime dir"

mkdir /run/user/1000
chmod 700 /run/user/1000

log "Starting services"

sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/seatd /var/service
sudo ln -s /etc/sv/iwd /var/service
sudo ln -s /etc/sv/bluetoothd /var/service


log "Cleaning up"
cd ..
rm -f -R swayos.github.io
check "$?" "rm"


log "Changing shell to zsh"
chsh -s /bin/zsh
check "$?" "chsh"


log "Setup is done, please log out and log in back again ( type exit )"
