#!/bin/bash
#
# This script installs SwayOS on a pre-installed void linux
# A user with sudo permissions and a live network connection is needed

# for nvidia drivers and steam :
# sudo xbps-install void-repo-nonfree void-repo-multilib
# sudo xbps-install nvidia steam libgcc-32bit libstdc++-32bit libdrm-32bit libglvnd-32bit mesa-dri-32bit

# In case of wifi not starting
# echo 'rfkill unblock all' | sudo tee -a /etc/rc.local

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
sudo xbps-install -Syu
check "$?" "Update xbps/system"
log "xbps/system updated"

# clean package cache
sudo xbps-remove -yO

# remove orphaned packages
sudo xbps-remove -yo

# purge old kernels...
sudo vkpurge rm all

log "Install base tools"
sudo xbps-install -Sy \
     bc \
     wget \
     zsh \
     zsh-autosuggestions
check "$?" "Install base tools"
log "basae tools installed"

log "Install nonfree repo"
sudo xbps-install -Sy \
     void-repo-nonfree

log "Install Sway environment"
sudo xbps-install -Sy \
     Waybar \
     blueman \
     bluez \
     brightnessctl \
     cups \
     cups-filters \
     chromium \
     chromium-widevine \
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
     ttf-ubuntu-font-family \
     wireplumber \
     wl-clipboard \
     wofi \
     xdg-desktop-portal-wlr \
     wob \
     iwgtk \
     octoxbps \
     wdisplays

check "$?" "Install Sway environment"
log "Sway environment installed"

log "Install dev tools"
sudo xbps-install -Sy \
     git \
     gcc \
     make \
     meson \
     ninja \
     pkg-config \
     wayland-protocols
check "$?" "Install dev tools"
log "Dev tools installed"


log "Clone swayOS repo"
git clone https://github.com/swayos/swayos.github.io.git
check "$?" "GIT SWAYOS"
cd swayos.github.io
git switch dev


log "Copy settings to home folder"
cp -f -R home/. ~/
check "$?" "Copy settings to home folder"
log "Settings copied"
rm -rf swayos.github.io


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
echo "$USER ALL=NOPASSWD:/sbin/reboot,/sbin/poweroff,/sbin/zzz" | sudo tee -a /etc/sudoers
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


log "Adding start xdg-desktop portal for screen sharing"
echo '# startup pipewire and xdg-desktop-portal for audio and screen sharing' | sudo tee -a $HOME/.config/sway/config
echo 'exec ~/.pipewire.sh' | sudo tee -a $HOME/.config/sway/config
check "$?" "Adding start xdg-desktop portal for screen sharing"
log "start added"


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


log "Install deps for FFMPEG 5.1.2"
sudo xbps-install -Sy \
     perl \
     yasm \
     alsa-lib-devel \
     bzip2-devel \
     libxcb-devel \
     liblzma-devel \
     SDL2-devel \
     sndio-devel \
     zlib-devel \
     frei0r-plugins \
     libcdio-paranoia-devel \
     rubberband-devel \
     libvidstab-devel \
     x264-devel \
     x265-devel \
     xvidcore-devel \
     fdk-aac-devel \
     libtls-devel \
     gmp-devel \
     chromaprint-devel \
     libgcrypt-devel \
     ladspa-sdk \
     lcms2-devel \
     libaom-devel \
     libass-devel \
     libbluray-devel \
     libcaca-devel \
     celt-devel \
     codec2-devel \
     libdav1d-devel \
     libdrm-devel \
     fontconfig-devel \
     freetype-devel \
     fribidi-devel \
     glslang-devel \
     SPIRV-Tools-devel \
     libgme-devel \
     libgsm-devel \
     jack-devel \
     libmodplug-devel \
     lame-devel \
     libopencv4-devel \
     libopenjpeg2-devel \
     libopenmpt-devel \
     opus-devel \
     libplacebo-devel \
     libpulseaudio \
     rabbitmq-c-devel \
     librist-devel \
     librsvg-devel \
     librtmp-devel \
     snappy-devel \
     libsoxr-devel \
     speex-devel \
     srt-devel \
     libssh-devel \
     libtheora-devel \
     twolame-devel \
     libvorbis-devel \
     libvpx6-devel \
     libwebp-devel \
     libxml2-devel \
     zimg-devel \
     lilv-devel \
     lv2 \
     libopenal-devel \
     mesa \
     openssl-devel \
     vapoursynth-devel \
     ocl-icd-devel \
     libmysofa-devel \
     vulkan-loader \
     libva-devel \
     libvdpau-devel \
     nv-codec-headers \
     libsvt-av1-devel
		
check "$?" "Install deps for FFMPEG 5.1.2"
log "Deps for FFMPEG 5.1.2 installed"

log "Building FFMPEG 5.1.2"
wget https://ffmpeg.org/releases/ffmpeg-5.1.2.tar.gz
check "$?" "WGET FFMPEG"
tar -xvzf ffmpeg-5.1.2.tar.gz
check "$?" "TAR FFMPEG"
cd ffmpeg-5.1.2
./configure \
    --prefix='/usr' \
    --extra-cflags='-I/opt/cuda/include' \
    --extra-ldflags='-L/opt/cuda/lib64' \
    --disable-stripping \
    --enable-shared \
    --enable-static \
    --enable-nonfree \
    --enable-gpl \
    --enable-version3 \
    --enable-libxcb \
    --enable-frei0r \
    --enable-libcdio \
    --enable-librubberband \
    --enable-libvidstab \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libfdk-aac \
    --enable-libtls \
    --enable-gmp \
    --enable-chromaprint \
    --enable-gcrypt \
    --enable-ladspa \
    --enable-lcms2 \
    --enable-libaom \
    --enable-libass \
    --enable-libbluray \
    --enable-libcaca \
    --enable-libcelt \
    --enable-libcodec2 \
    --enable-libdav1d \
    --enable-libdrm \
    --enable-libfontconfig \
    --enable-libfreetype \
    --enable-libfribidi \
    --enable-libglslang \
    --enable-libgme \
    --enable-libgsm \
    --enable-vapoursynth \
    --enable-openssl \
    --enable-opengl \
    --enable-openal \
    --enable-lv2 \
    --enable-libzimg \
    --enable-libxml2 \
    --enable-libwebp \
    --enable-libvorbis \
    --enable-libtwolame \
    --enable-libtheora \
    --enable-libssh \
    --enable-libsrt \
    --enable-libspeex \
    --enable-libsoxr \
    --enable-librtmp \
    --enable-librsvg \
    --enable-librist \
    --enable-librabbitmq \
    --enable-libpulse \
    --enable-libplacebo \
    --enable-libopus \
    --enable-libopenmpt \
    --enable-libopenjpeg \
    --enable-libmp3lame \
    --enable-libmodplug \
    --enable-libjack \
    --enable-opencl \
    --enable-libvpx \
    --enable-libmysofa \
    --enable-vaapi \
    --enable-vdpau \
    --enable-nvenc \
    --enable-nvdec

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
sudo xbps-install -y libpng-devel freetype-devel libglvnd-devel glew-devel wayland-devel libxkbcommon-devel
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
sudo xbps-install -y SDL2-devel jpeg-devel jbig2dec-devel libopenjpeg2-devel harfbuzz-devel
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
sudo xbps-install -y mupdf-devel gumbo-parser-devel mujs-devel
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


log "Setup is done, please log out and log in back again ( type exit )"
