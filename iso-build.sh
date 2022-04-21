#!/bin/sh
#
# This scripts creates a bootable ISO that installs the base image and sets the install up
#

# Set up logging
exec 1> >(tee "tmp/iso_build_out")
exec 2> >(tee "tmp/iso_build_err")

# cleanup first, tmp/iso stayed there for debugging

sudo rm -r tmp/isowork
sudo rm -r tmp/iso

# copy/move needed folders under airootfs

# copy base image
cp swayos.img.gz isoc/airootfs/root/

# copy installer script
cp iso-install.sh isoc/airootfs/root/

# create iso
sudo mkarchiso -v -w tmp/isowork -o tmp isoc
