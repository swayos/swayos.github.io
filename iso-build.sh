#!/bin/sh
#
# This scripts creates a bootable ISO with pre-downloaded packages and pre-built aur packages for offline install
#
# Set up logging
exec 1> >(tee "tmp/swayos_build_out")
exec 2> >(tee "tmp/swayos_build_err")

ARCH="x86_64"
MIRROR="https://mirrors.kernel.org/archlinux/"

# clear tmp dir

sudo rm -rf tmp/*
mkdir tmp/repo
mkdir tmp/tmpdb

# copy archiso config

cp -r /usr/share/archiso/configs/releng/ ./tmp/iso/

# narrow down live cd

sed -i '/linux-firmware-marvell/d' tmp/iso/packages.x86_64
sed -i '/js78/d' tmp/iso/packages.x86_64
sed -i '/perl/d' tmp/iso/packages.x86_64
sed -i '/python/d' tmp/iso/packages.x86_64
sed -i '/icu/d' tmp/iso/packages.x86_64
sed -i '/sof-firmware/d' tmp/iso/packages.x86_64
sed -i '/speex/d' tmp/iso/packages.x86_64
sed -i '/espeak-ng/d' tmp/iso/packages.x86_64
sed -i '/liblouis/d' tmp/iso/packages.x86_64

sed -i '/TIMEOUT 150/d' tmp/iso/syslinux/archiso_sys.cfg
echo "TIMEOUT 0" >> tmp/iso/syslinux/archiso_sys.cfg

# add dialog as extra package to live cd

echo "dialog" >> tmp/iso/packages.x86_64

# start iso-install.sh on login

sed -i '$ d' tmp/iso/airootfs/root/.zlogin
echo "sh iso-install.sh" >> tmp/iso/airootfs/root/.zlogin

# copy splash image

cp -f pics/splash.png tmp/iso/syslinux

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

mv tmp/repo tmp/iso/airootfs/root/
cp -r home tmp/iso/airootfs/root/
cp -r font tmp/iso/airootfs/root/
cp -r pacs tmp/iso/airootfs/root/
cp iso-install.sh tmp/iso/airootfs/root/
cp iso-pacman.conf tmp/iso/airootfs/root/

# create iso

sudo mkarchiso -v -w ./tmp/isowork -o ./tmp ./tmp/iso
