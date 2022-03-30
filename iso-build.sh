#!/bin/sh
#
# This scripts creates a bootable ISO with pre-downloaded packages and pre-built arch packages for offline install
#

ARCH="x86_64"
MIRROR="https://mirrors.kernel.org/archlinux/"

# clear tmp dir

sudo rm -rf tmp/*
mkdir tmp/repo
mkdir tmp/tmpdb

# reset iso dir and copy actual archiso config

rm -rf iso
cp -r /usr/share/archiso/configs/releng/ ./iso/

# add dialog as extra package to live cd

echo "dialog" >> iso/packages.x86_64

# start iso-install.sh on login

sed -i '$ d' iso/airootfs/root/.zlogin
echo "sh iso-install.sh" >> iso/airootfs/root/.zlogin

# update local packages & keyring

sudo pacman --noconfirm -Syu

# download package databases

wget -o /dev/null -P tmp/repo "${MIRROR}/community/os/${ARCH}/community.db"
wget -o /dev/null -P tmp/repo "${MIRROR}/core/os/${ARCH}/core.db"
wget -o /dev/null -P tmp/repo "${MIRROR}/extra/os/${ARCH}/extra.db"
wget -o /dev/null -P tmp/repo "${MIRROR}/multilib/os/${ARCH}/multilib.db"

# download packages

cat pac-base pac-swayos pac-aurdeps > pac-offline
sudo pacman --noconfirm -Syw --cachedir tmp/repo --dbpath tmp/tmpdb - < pac-offline

# sudo pacman --noconfirm -Syw --cachedir tmp/repo --dbpath tmp/tmpdb base linux linux-firmware sudo git zsh zsh-autosuggestions iwd bluez bluez-utils blueman pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-media-session xdg-desktop-portal-wlr xorg-xwayland wayland-protocols sway swayidle swaylock grim slurp waybar wofi brightnessctl foot nautilus libreoffice-fresh gnome-system-monitor system-config-printer feh cups ttf-ubuntu-font-family terminus-font polkit-gnome wl-clipboard openbsd-netcat unzip meson pavucontrol scdoc grub gobject-introspection dbus-glib vte3 appstream-glib archlinux-appstream-data

# create custom db

repo-add tmp/repo/custom.db.tar.gz tmp/repo/*.pkg.tar.zst

# download and compile needed aur packages

cd tmp/repo

cat ../../pac-aur | while read line 
do
    git clone https://aur.archlinux.org/$line.git
    cd $line
    makepkg -s --skippgpcheck
    cd ..
done

cd ../..

# git clone https://aur.archlinux.org/wob.git
# git clone https://aur.archlinux.org/wlogout.git
# git clone https://aur.archlinux.org/wdisplays.git
# git clone https://aur.archlinux.org/iwgtk.git
# git clone https://aur.archlinux.org/libpamac-aur.git
# git clone https://aur.archlinux.org/pamac-aur.git
# git clone https://aur.archlinux.org/google-chrome.git
# git clone https://aur.archlinux.org/nerd-fonts-terminus.git
# git clone https://github.com/milgra/sway-overview

# build aur packages

# cd wob
# makepkg -s --skippgpcheck
# cd ../wlogout
# makepkg -s --skippgpcheck
# cd ../wdisplays
# makepkg -s --skippgpcheck
# cd ../iwgtk
# makepkg -s --skippgpcheck
# cd ../libpamac-aur
# makepkg -s --skippgck
# cd ../pamac-aur
# makepkg -s --skippgck
# cd ../google-chrome
# makepkg -s --skippgpcheck
# cd ../nerd-fonts-terminus
# makepkg -s --skippgpcheck
# cd ../sway-overview
# meson build
# ninja -C build
# cd ../../..

# copy/move needed folders under airootfs

mv tmp/repo iso/airootfs/root/
cp -r home iso/airootfs/root/
cp -r font iso/airootfs/root/
cp iso-install.sh iso/airootfs/root/
cp iso-pacman.conf iso/airootfs/root/
cp pac-aur iso/airootfs/root/
cp pac-offline iso/airootfs/root/

# create iso

sudo mkarchiso -v -w ./tmp/isowork -o ./tmp ./iso
