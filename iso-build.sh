#!/bin/sh
#
# This scripts creates a bootable ISO that installs the base image and sets the install up
#

# Set up logging
exec 1> >(tee "temp/iso_build_out")
exec 2> >(tee "temp/iso_build_err")

# cleanup first, temp/iso stayed there for debugging

sudo rm -r temp/isowork
sudo rm -r temp/iso
rm isoc/airootfs/root/swayos.img.gz
rm isoc/airootfs/root/iso-install.sh

# copy/move needed folders under airootfs

# copy base image
mv swayos.img.gz isoc/airootfs/root/

# copy installer script
cp iso-install.sh isoc/airootfs/root/

# create version info
echo "iso-build timestamp: $(date)" > isoc/airootfs/root/swayos_setup_ver

# create iso
sudo mkarchiso -v -w temp/isowork -o temp isoc
