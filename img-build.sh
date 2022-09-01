#!/bin/bash
#
# This script creates a base image pac-strapped with the needed packages
#

# reset temp
sudo rm -rf temp
mkdir temp

# Set up logging
exec 1> >(tee "temp/img_build_out")
exec 2> >(tee "temp/img_build_err")

# Create disk image for package install
rm swayos.img
rm swayos.img.gz

dd if=/dev/zero of=swayos.img bs=1M count=6500
mkfs.ext4 -F swayos.img

# Pacstrap all needed packages
sudo pacman -Sy --needed arch-install-scripts
sudo mkdir -p /mnt/swayos
sudo mount swayos.img /mnt/swayos
cat pacs/arch/img pacs/arch/swayos pacs/arch/aurdeps > temp/pacs
sudo pacstrap /mnt/swayos - < temp/pacs

# Precompile, copy and install aur packages to image
cd temp
cat ../pacs/arch/aur | while read package
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
sudo mkdir -p /mnt/swayos/usr/share/fonts/TTF
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
