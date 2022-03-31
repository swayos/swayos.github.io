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

# narrow down live cd

sed -i '/linux-firmware-marvell/d' iso/packages.x86_64
sed -i '/js78/d' iso/packages.x86_64
sed -i '/perl/d' iso/packages.x86_64
sed -i '/python/d' iso/packages.x86_64
sed -i '/icu/d' iso/packages.x86_64
sed -i '/sof-firmware/d' iso/packages.x86_64
sed -i '/speex/d' iso/packages.x86_64
sed -i '/espeak-ng/d' iso/packages.x86_64
sed -i '/liblouis/d' iso/packages.x86_64

sed -i '/TIMEOUT 150/d' iso/syslinux/archiso_sys.cfg
echo "TIMEOUT 0" >> iso/syslinux/archiso_sys.cfg

# add dialog as extra package to live cd

echo "dialog" >> iso/packages.x86_64

# start iso-install.sh on login

sed -i '$ d' iso/airootfs/root/.zlogin
echo "sh iso-install.sh" >> iso/airootfs/root/.zlogin

# copy splash image

cp -f pics/splash.png iso/syslinux

# update local packages & keyring

sudo pacman --noconfirm -Syu

# download package databases

wget -o /dev/null -P tmp/repo "${MIRROR}/community/os/${ARCH}/community.db"
wget -o /dev/null -P tmp/repo "${MIRROR}/core/os/${ARCH}/core.db"
wget -o /dev/null -P tmp/repo "${MIRROR}/extra/os/${ARCH}/extra.db"
wget -o /dev/null -P tmp/repo "${MIRROR}/multilib/os/${ARCH}/multilib.db"

# download packages

cat pacs/base pacs/swayos pacs/aurdeps > pacs/offline
sudo pacman --noconfirm -Syw --cachedir tmp/repo --dbpath tmp/tmpdb - < pacs/offline

# create custom db

repo-add tmp/repo/custom.db.tar.gz tmp/repo/*.pkg.tar.zst

# download and compile needed aur packages

cd tmp/repo

cat ../../pacs/aur | while read line 
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
cp -r pacs iso/airootfs/root/
cp iso-install.sh iso/airootfs/root/
cp iso-pacman.conf iso/airootfs/root/

# create iso

sudo mkarchiso -v -w ./tmp/isowork -o ./tmp ./iso
