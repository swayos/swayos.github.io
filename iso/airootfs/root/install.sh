# popup keyboard map selector, default is us

# popup disk selector

# popup entire disk will be formatted

# ask for root password

# ask for user

# ask for user password

# format disk with uefi or mbt partition schema

# mount disk

# pacstrap packages

pacstrap -C pacman.conf /mnt base linux linux-firmware sudo git zsh zsh-autosuggestions iwd bluez bluez-utils blueman pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-media-session xdg-desktop-portal-wlr xorg-xwayland wayland-protocols sway swayidle swaylock grim slurp waybar wofi brightnessctl foot nautilus libreoffice-fresh gnome-system-monitor system-config-printer feh cups ttf-ubuntu-font-family terminus-font polkit-gnome wl-clipboard openbsd-netcat unzip meson pavucontrol scdoc

# copy aur packages under target/home/#$user/swayos

# copy fonts under target/usr/share/fonts

# copy home directory stuff under target/home/$user/

# chroot into new root

# start services

# install aur packages

# change shell to zsh

# cleanup
