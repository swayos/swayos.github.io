#!/bin/sh
#
# This script finishes the installation with chroot from the Live CD after pacstrap is finished
#

# chroot into new root

log "Chroot into /mnt"
arch-chroot /mnt
check "$?" "arch-chroot"

# setup grub

log "Setup grub"
grub-install --target=i386-pc $bootdev
check "$?" "grub-install"

# start services

log "starting services"
sudo systemctl enable systemd-networkd --now
sudo systemctl enable iwd --now
sudo systemctl enable bluetooth --now
sudo systemctl enable cups --now
check "$?" "systemctl enable"

# install aur packages

log "Installing aur packages"
cd /tmp/wob
ls *.pkg.tar.zst | pacman -U
cd /tmp/wlogout
ls *.pkg.tar.zst | pacman -U
cd /tmp//wdisplays
ls *.pkg.tar.zst | pacman -U
cd /tmp/iwgtk
ls *.pkg.tar.zst | pacman -U
cd /tmp/pamac-aur
ls *.pkg.tar.zst | pacman -U
cd /tmp/google-chrome
ls *.pkg.tar.zst | pacman -U
cd /tmp/nerd-fonts-terminus
ls *.pkg.tar.zst | pacman -U
cd /tmp/sway-overview
meson build
ninja -C build
ninja -C build install

# change shell to zsh

log "Changing shell"
chsh -s /bin/zsh
check "$?" "chsh"

# copy setup log to home folder

cp swayos_setup_log $("/home/$username")

