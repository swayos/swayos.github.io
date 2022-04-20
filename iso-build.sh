#!/bin/sh
#
# This scripts creates a bootable ISO with pre-downloaded packages and pre-built aur packages for offline install
#

# Set up logging
exec 1> >(tee "tmp/iso_build_out")
exec 2> >(tee "tmp/iso_build_err")

# cleanup first, tmp/iso stayed there for debugging

sudo rm -r tmp/isowork
sudo rm -r tmp/iso

# copy archiso profile

cp -r /usr/share/archiso/configs/baseline/ ./tmp/iso/

# create root dir in airootfs

mkdir tmp/iso/airootfs/root

# add extra packages

echo "mc" >> tmp/iso/packages.x86_64
echo "grub" >> tmp/iso/packages.x86_64
echo "dialog" >> tmp/iso/packages.x86_64
echo "parted" >> tmp/iso/packages.x86_64
echo "dosfstools" >> tmp/iso/packages.x86_64
echo "arch-install-scripts" >> tmp/iso/packages.x86_64

# start iso-install.sh on login

# sed -i '$ d' tmp/iso/airootfs/root/.zlogin
echo "sh iso-install.sh" >> tmp/iso/airootfs/root/.zlogin

# copy splash image
cp -f pics/splash.png tmp/iso/syslinux
cp -f util/syslinux.cfg tmp/iso/syslinux/
cp -f util/syslinux-linux.cfg tmp/iso/syslinux/

# copy/move needed folders under airootfs

# base image
cp swayos.img.gz tmp/iso/airootfs/root/

# installer script
cp iso-install.sh tmp/iso/airootfs/root/

# setup autostart
cp util/.profile tmp/iso/airootfs/root/

# auto login
cp -r util/getty@tty1.service.d tmp/iso/airootfs/etc/systemd/system/

# create iso
sudo mkarchiso -v -w ./tmp/isowork -o ./tmp ./tmp/iso
