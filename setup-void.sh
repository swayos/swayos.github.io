#!/bin/bash
#
# This script installs SwayOS on a pre-installed void linux
# A user with sudo permissions and a live network connection is needed

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

# install packages

log "Update xbps/system"
sudo xbps-install -u xbps
sudo xbps-install -Su
check "$?" "Update xbps/system"
log "xbps/system updated"


log "Install base tools"
sudo xbps-install \
     bc \
     wget \
     zsh \
     zsh-autosuggestions
check "$?" "Install base tools"
log "basae tools installed"

 
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
check "$?" "Install Sway environment"
log "Sway environment installed"


log "Install dev tools"
sudo xbps-install \
     git \
     gcc \
     meson \
     ninja \
     pkg-config \
     wayland-protocols
check "$?" "Install dev tools"
log "Dev tools installed"


log "Install deps for FFMPEG 5.1.2"
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
check "$?" "Install deps for FFMPEG 5.1.2"
log "Deps for FFMPEG 5.1.2 installed"


log "Building FFMPEG 5.1.2"
wget https://ffmpeg.org/releases/ffmpeg-5.1.2.tar.gz
check "$?" "WGET FFMPEG"
tar -xvzf ffmpeg-5.1.2.tar.gz
check "$?" "TAR FFMPEG"
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
check "$?" "CONF FFMPEG"
make
check "$?" "MAKE FFMPEG"
sudo make install
check "$?" "ISNTALL FFMPEG"
cd ..
rm -rf ffmpeg-5.1.2
log "FFMPEG 5.1.2 installed"


log "Update library cache"
sudo ldconfig
check "$?" "Update library cache"
log "Library cache updated"


log "Install sov"
git clone https://github.com/milgra/sov
check "$?" "GIT SOV"
sudo xbps-install libpng-devel freetype-devel libglvnd-devel glew-devel wayland-devel libxkbcommon-devel
check "$?" "DEPS SOV"
cd sov
meson setup build --buildtype=release
check "$?" "BUILD SOV"
ninja -C build
check "$?" "BUILD SOV"
sudo ninja -C build install
check "$?" "INSTALL SOV"
cd ..
rm -rf sov
log "sov installed"


log "Install wcp"
git clone https://github.com/milgra/wcp
check "$?" "GIT WCP"
cd wcp
meson setup build --buildtype=release
check "$?" "BUILD WCP"
ninja -C build
check "$?" "BUILD WCP"
sudo ninja -C build install
check "$?" "INSTALL WCP"
cd ..
rm -rf wcp
check "$?" "BUILD WCP"


log "Install vmp"
git clone https://github.com/milgra/vmp
check "$?" "GIT VMP"
sudo xbps-install SDL2-devel jpeg-devel jbig2dec-devel libopenjpeg2-devel harfbuzz-devel
check "$?" "DEPS VMP"
cd vmp
meson setup build --buildtype=release
check "$?" "BUILD VMP"
ninja -C build
check "$?" "BUILD VMP"
sudo ninja -C build install
check "$?" "INSTALL VMP"
cd ..
rm -rf vmp
log "vmp installed"


log "Install mmfm"
git clone https://github.com/milgra/mmfm
check "$?" "GIT MMFM"
sudo xbps-install mupdf-devel gumbo-parser-devel mujs-devel
check "$?" "DEPS MMFM"
cd mmfm
meson setup build --buildtype=release
check "$?" "BUILD MMFM"
ninja -C build
check "$?" "BUILD MMFM"
sudo ninja -C build install
check "$?" "INSTALL MMFM"
cd ..
rm -rf mmfm
log "mmfm installed"


log "Install Google Chrome"
git clone https://github.com/void-linux/void-packages.git
cd void-packages/
./xbps-src binary-bootstrap
echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
./xbps-src pkg google-chrome
sudo xbps-install google-chrome --repository=hostdir/binpkgs/nonfree
cd ..
rm -rf void-packages
check "$?" "Install Google Chrome"
log "Google Chrome installed"


log "Clone swayOS repo"
git clone https://github.com/swayos/swayos.github.io.git
check "$?" "GIT SWAYOS"
cd swayos.github.io
log "Copy fonts to font directory"
sudo cp -f font/*.* /usr/share/fonts/
check "$?" "Copy fonts to font directory"
log "Fonts copied"
log "Copy settings to home folder"
cp -f -R home/. ~/
check "$?" "Copy settings to home folder"
log "Settings copied"
rm -rf swayos.github.io


# setup environment


#log "Force unblock"
#echo 'rfkill unblock all' | sudo tee -a /etc/rc.local


log "Add user to needed groups"
sudo usermod -a $USER -G _seatd
sudo usermod -a $USER -G bluetooth
check "$?" "Add user to needed groups"
log "User added to needed groups"


log "Disable beeping"
echo 'rmmod pcspkr' | sudo tee -a /etc/modprobe.d/blacklist.conf
check "$?" "Disable beeping"
log "Beeping disabled"


log "Disable grub menu"
echo 'GRUB_TIMEOUT=0' | sudo tee -a /etc/default/grub
echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub
echo 'GRUB_CMDLINE_LINUX_DEFAULT="loglevel=1 quiet splash"' | sudo tee -a /etc/default/grub
check "$?" "Disable grub menu"
log "Grub menu disabled"


log "Enable shutdown/reboot/suspend"
echo '$USER ALL=NOPASSWD:/sbin/reboot,/sbin/shutdown,/sbin/suspend' | sudo tee -a /etc/default/grub
check "$?" "Enable shutdown/reboot/suspend"
log "Shutdown/reboot/suspend enabled"


log "Disable wpa_supplicant"
sudo rm /var/service/wpa_supplicant
check "$?" "Disable wpa_supplicant"
log "wpa_supplicant disabled"


log "Disable iwd udevd collosion"
echo '[General]' | sudo tee -a /etc/iwd/main.conf
echo 'UseDefaultInterface=true' | sudo tee -a /etc/iwd/main.conf
check "$?" "Disabel iwd udevd collosion"
log "iwd udevd collosion disabled"


log "Enable services"
sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/iwd /var/service
sudo ln -s /etc/sv/seatd /var/service
sudo ln -s /etc/sv/bluetoothd /var/service
sudo ln -s /etc/sv/pipewire /var/service
sudo ln -s /etc/sv/pipewire-pulse /var/service
check "$?" "Enable services"
log "Services enabled"


log "Changing shell to zsh"
chsh -s /bin/zsh
check "$?" "Changing shell to zsh"
log "Shell changed to zsh"


log "Setup is done, please log out and log in back again ( type exit )"
