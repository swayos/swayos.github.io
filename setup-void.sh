#!/bin/bash
#
# This script installs SwayOS on a pre-installed void linux
# A user with sudo permissions and a live network connection is needed
#
# default void install

# Set up logging
exec 1> >(tee "swayos_setup_out")
exec 2> >(tee "swayos_setup_err")

log(){
    echo "*********** $1 ***********"
    now=$(date +"%T")
    echo "$now $1" >> ~/swayos_setup_log
}

check(){
    if [ "$1" != 0 ]; then
	echo "$2 error : $1" | tee -a ~/swayos_setup_log
	exit 1
    fi
}


log "Disable beeping"

echo 'rmmod pcspkr' | sudo tee -a /etc/modprobe.d/blacklist.conf


#log "Force unblock"
#echo 'rfkill unblock all' | sudo tee -a /etc/rc.local


log "Disable grub menu"

echo 'GRUB_TIMEOUT=0' | sudo tee -a /etc/default/grub
echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub
echo 'GRUB_CMDLINE_LINUX_DEFAULT="loglevel=1 quiet splash"' | sudo tee -a /etc/default/grub


log "Enable shutdown/reboot/suspend"

echo '$USER ALL=NOPASSWD:/sbin/reboot,/sbin/shutdown,/sbin/suspend' | sudo tee -a /etc/default/grub


log "Update xbps"

sudo xbps-install -u xbps


log "System update"

sudo xbps-install -Su


log "Install base tools"

sudo xbps-install \
     bc \
     wget \
     zsh \
     zsh-autosuggestions

 
log "Install Sway environment"

sudo xbps-install \
 Adapta \
 Waybar \
 blueman \
 bluez \
 brightnessctl \
 cups \
 emacs \
 foot \
 grim \
 grub \
 iwd \
 libreoffice \
 libspa-bluetooth \
 mesa-dri \
 nautilus \
 pamixer \
 pavucontrol \
 pipewire \
 seatd \
 slurp \
 sway \
 swaybg \
 swayidle \
 swaylock \
 system-config-printer \
 terminus-font \
 wireplumber \
 wl-clipboard \
 wofi \
 xdg-desktop-portal-wlr \
 wob \
 iwgtk


log "Enable services"

sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/iwd /var/service
sudo ln -s /etc/sv/seatd /var/service
sudo ln -s /etc/sv/bluetoothd /var/service
sudo ln -s /etc/sv/pipewire /var/service
sudo ln -s /etc/sv/pipewire-pulse /var/service


log "Disable wpa_supplicant"

sudo rm /var/service/wpa_supplicant


log "Disable iwd udevd collosion"

echo '[General]' | sudo tee -a /etc/iwd/main.conf
echo 'UseDefaultInterface=true' | sudo tee -a /etc/iwd/main.conf


log "Add user to groups"

sudo usermod -a $USER -G _seatd
sudo usermod -a $USER -G bluetooth


log "Changing shell to zsh"

chsh -s /bin/zsh


log "Installing dev tools"

sudo xbps-install \
 git \
 pkg-config \
 meson \
 wayland-protocols

if [ ! -d void-packages ]; then

    log "Installing Google Chrome"
    git clone https://github.com/void-linux/void-packages.git && cd void-packages/ && ./xbps-src binary-bootstrap && echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf && ./xbps-src pkg google-chrome
    sudo xbps-install google-chrome --repository=hostdir/binpkgs/nonfree

fi

log "Installing latest FFMPEG"

sudo xbps-install \
     x264-devel \
     x265-devel \
     gcc \
     make \
     nasm \
     yasm \
     zlib-devel \
     bzip2-devel \
     freetype-devel \
     alsa-lib-devel \
     libXfixes-devel \
     libXext-devel \
     libXvMC-devel \
     libxcb-devel \
     lame-devel \
     libtheora-devel \
     libvorbis-devel \
     xvidcore-devel \
     jack-devel \
     SDL2-devel \
     libcdio-paranoia-devel \
     librtmp-devel \
     libmodplug-devel \
     gnutls-devel \
     speex-devel \
     celt-devel \
     harfbuzz-devel \
     libass-devel \
     opus-devel \
     ocl-icd-devel \
     libbs2b-devel \
     libvidstab-devel \
     libva-devel \
     libvdpau-devel \
     v4l-utils-devel \
     fdk-aac-devel \
     libvpx-devel \
     libaom-devel \
     libdav1d-devel \
     zimg-devel \
     libwebp-devel \
     libmysofa-devel \
     libdrm-devel \
     libsvt-av1-devel \
     srt-devel \
     librist-devel

if [ ! -d ffmpeg-5.1.2 ]; then
    wget https://ffmpeg.org/releases/ffmpeg-5.1.2.tar.gz
    tar -xvzf ffmpeg-5.1.2.tar.gz
    cd ffmpeg-5.1.2
    ./configure \
	--prefix=/usr \
	--pkg-config-flags="--static" \
	--extra-cflags="-I$HOME/ffmpeg_build/include" \
	--extra-ldflags="-L$HOME/ffmpeg_build/lib" \
	--extra-libs=-lpthread \
	--extra-libs=-lm \
	--bindir="$HOME/bin" \
	--enable-gpl \
	--enable-libfdk_aac \
	--enable-libfreetype \
	--enable-libmp3lame \
	--enable-libopus \
	--enable-libvpx \
	--enable-libx264 \
	--enable-libx265 \
	--enable-nonfree \
	--enable-shared
    make
    sudo make install
    cd ..
fi


log "Updating library cache"
sudo ldconfig


log "Install sov"

git clone https://github.com/milgra/sov
sudo xbps-install meson ninja pkg-config clang libpng-devel freetype-devel libglvnd-devel glew-devel wayland-devel libxkbcommon-devel
cd sov
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..


log "Install wcp"

git clone https://github.com/milgra/wcp
cd wcp
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..


log "Install vmp"

git clone https://github.com/milgra/vmp
sudo xbps-install SDL2-devel jpeg-devel jbig2dec-devel libopenjpeg2-devel harfbuzz-devel
cd vmp
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..


log "Install mmfm"

git clone https://github.com/milgra/mmfm
sudo xbps-install mupdf-devel gumbo-parser-devel mujs-devel
cd mmfm
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..


log "Cloning swayOS repo"

git clone https://github.com/swayos/swayos.github.io.git
cd swayos.github.io


log "Copying terminus-ttf fonts to font directory"

sudo cp -f font/*.* /etc/fonts/
check "$?" "cp"


log "Copying settings to home folder"

cp -f -R home/. ~/
check "$?" "cp"


log "Cleaning up"

cd ..
rm -f -R swayos.github.io
check "$?" "rm"

# dconf-editor?
# remove ffmpeg src?
# remove sov, wcp, vmp, mmfm src?
# remove chrome src

log "Setup is done, please log out and log in back again ( type exit )"
