#!/bin/sh
#
# This scripts creates a bootable ISO with pre-downloaded packages and pre-built aur packages for offline install
#
# Set up logging
exec 1> >(tee "swayos_build_out")
exec 2> >(tee "swayos_build_err")

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
