#!/bin/bash
#
# This script creates a base image pac-strapped with the needed packages
#

# reset tmp
sudo rm -rf tmp
mkdir tmp

# Set up logging
exec 1> >(tee "tmp/img_build_out")
exec 2> >(tee "tmp/img_build_err")

# Create disk image for package install
dd if=/dev/zero of=swayos.img bs=1M count=5500
mkfs.ext4 -F swayos.img

# Pacstrap all needed packages
sudo mkdir -p /mnt/swayos
sudo mount swayos.img /mnt/swayos
cat pacs/base pacs/swayos > tmp/pacs
sudo pacstrap /mnt/swayos - < tmp/pacs

# Precompile, copy and install aur packages to image
cd tmp
cat ../pacs/aur | while read package
do
    # Clone aur repo
    git clone https://aur.archlinux.org/$package.git
    # Build
    cd $package
    makepkg -s --skippgpcheck
    cd ..
    # Move to target image
    sudo cp -r $package /mnt/swayos/home/
    # Install on target image
    rel_path=$(ls $package/*.pkg.tar.zst)
    sudo arch-chroot /mnt/swayos pacman --noconfirm -U "/home/$rel_path"
    # cleanup
    sudo rm -r /mnt/swayos/home/$package
done
cd ..

# Copy fonts
sudo cp -r font/*.* /mnt/swayos/usr/share/fonts/TTF/

# Chown font files
# sudo arch-chroot /mnt/swayos chown --recursive "root:root" /usr/share/fonts/TTF

# Copy config files
sudo cp -f -R home /mnt/swayos/home/configs

# Unmount
sudo umount /mnt/swayos

# shrink
e2fsck -f -y swayos.img
resize2fs -M swayos.img

# Zip
gzip swayos.img
