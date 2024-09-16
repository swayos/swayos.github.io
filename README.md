# SwayOS 3.0


SwayOS is a productivity-oriented minimalist and super elegant desktop layer for unix-like operating systems. It is a collection of configuration files, open source applications and open source applications created exclusively for SwayOS.

[<img src="pics/swayos.png" width="1000">](pics/swayos.png)

## UI Structure of SwayOS

SwayOS's UI has two parts : the status bar ( on top by default ) and the window area under the status bar.
The status bar has the following sections from left to right : workspace block ( indicators ) , hardware status block ( in the center by default ), date and clock.

## Usage of SwayOS ##

| Binding | Action | 
| -----------| -------| 
|**Left click on status bar**|open/close control panel|
|**Right click on status bar**|open/close overview|
|**WIN + SPACE**|open application|
|**WIN + ENTER**|open terminal|
|**WIN + SHIFT + ENTER**|open browser|
|**WIN + SHIFT + Q**|close focused window|
|**WIN + numbers**|switch to workspace / open overview ( long press )|
|**WIN + SHIFT + numbers**|move focused window to workspace with given number|
|**WIN + arrows**|set focus to neighbouring windows|
|**WIN + SHIFT + arrows**|move window to a new position inside the workspace|
|**WIN + R**|resize mode, press ESC to quit|
|**WIN + SHIFT + SPACE**|toggle/untoggle floating over a window|

## Donations

paypal : [https://paypal.me/milgra](https://paypal.me/milgra)  
patreon : [https://www.patreon.com/milgra](https://www.patreon.com/milgra)  
bitcoin : 37cSZoyQckihNvy939AgwBNCiutUVN82du      

## Setup ##

## Part One - Install sway and the basic utilities first with your package manager ##

```
sway
foot
wofi
ubuntu-font
```

Then clone the swayos github repo and copy the default config files to ~/.config

```
git clone https://github.com/swayos/swayos.github.io
cp -R swayos.github.io/home/.config ~/
```

Now you can start sway by typing ```sway``` and open a terminal by pressing WIN+ENTER

*note : on non-systemd distributions ( e.g. void linux ) you will need seatd and to set XDG_RUNTIME_DIR also for running sway*

*note : if WIN+ENTER is not working set a different modifier key for sway in ~/.config/sway/config*

How to do it on Void Linux :
  
```
sudo xbps-install -Syu
sudo xpbs-install -y sway foot wofi ttf-ubuntu-font-family
sudo xbps-install -y seatd
sudo ln -s /etc/sv/seatd /var/service
sudo usermod -a $USER -G _seatd
sudo xbps-install -y git
git clone https://github.com/swayos/swayos.github.io
cp -R swayos.github.io/home/. ~/
exit
export XDG_RUNTIME_DIR=/tmp
sway
```

How to do it on Debian Bookworm :
  
```
sudo apt-get install software-properties-common
sudo apt-add-repository --component non-free
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install sway foot wofi fonts-ubuntu
sudo apt-get install git
git clone https://github.com/swayos/swayos.github.io
cp -R swayos.github.io/home/. ~/
sway
```

</details>

## Part Two - Installing Sway Overview ##

Install the dev tools to build

```
clang
meson
ninja
cmake
pkg-config
```

Install the needed dependencies

```
libpng
freetype
libglvnd
glew
wayland
wayland-protocols
libxkbcommon
```

Clone the repo, build and install

```
git clone https://github.com/milgra/sov
cd sov
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install
```

How to do it on Void Linux :
  
```
sudo xbps-install -y clang meson ninja cmake pkg-config
sudo xbps-install -y libpng-devel freetype-devel libglvnd-devel glew-devel wayland-devel libxkbcommon-devel wayland-protocols
git clone https://github.com/milgra/sov
cd sov
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install
```

How to do it on Debian Bookworm :
  
```
sudo apt-get install clang meson ninja-build cmake pkg-config
sudo apt-get install libpng-dev libfreetype-dev libglvnd-dev libglew-dev libwayland-dev libxkbcommon-dev wayland-protocols
git clone https://github.com/milgra/sov
cd sov
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install
```

Press WIN+SHIFT+E to exit sway and start it again. Now you can summon sway overview by pressing and holding CMD+1 or right clicking on the status bar. 
If fonts are too small or you want an other font change it under ~/.conifg/sov/html/main.css

## Part Three - Installing Wayland Control Panel ##

Clone the Kinetic UI Dameon repo, build and install

```
git clone https://github.com/milgra/kuid
cd kuid
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..
```

Clone the Wayland Control Panel repo, install

```
git clone https://github.com/milgra/wcp
cd wcp
mkdir ~/.config/wcp
cp wcp-template.sh ~/.config/wcp/wcp.sh
cp -R res ~/.config/wcp/
cd ..
```

Update ~/.config/wcp/wcp.sh to suit your needs, or use wcp-void.sh or wcp-debian.sh from the repo.

Press WIN+SHIFT+E to exit sway and start it again. Now you can summon wayland control panel by pressing WIN+P or by left clicking on the status bar ( The buttons/sliders won't work yet. )
If fonts are too small or you want an other font change it under ~/.conifg/wcp/res/main.css

## Part Four - Make SwayOS comfortable & Wayland Control Panel usable ##

Install ```grim``` and ```slurp``` for making screenshots

- Press WIN+PRTSRC to put a screenshot or WIN+SHIFT+PRTSCR to put a region under ~/Downloads. Create ~/Downloads directory if doesn't exist. Modify key bindings in ~/.config/sway/config

Install ```swayidle``` and ```swaylock``` 

- Press WIN+SHIFT+E to exit sway and start it again. Screen will lock in 2 minutes, computer will sleep in 4 minutes. Change these values in ~/.config/sway/config

Install ```wob``` for volume/brightness indication

- Restart sway, if you have pamixer and brightnessctl installed then press volume/brightness keys on the keyboard to make wob visible.
Modify key bindings in ~/.config/sway/config

Install ```brightnessctl``` for controlling monitor brightness

- Press brighntess keys on the keyboard to modify brightness
Modify key bindings in ~/.config/sway/config

Install ```pavuctl``` and ```pamixer``` for detailed audio control

- Press the volume icon on the control panel to open pavucontrol or bind a key in ~/.config/sway/config

Install ```wdisplays``` for display configuration

- Press the display icon on the control panel to open wdisplays or bind a key in ~/.config/sway/config

Install ```iwd``` and ```iwgtk``` for smooth wifi experience

- Press the wifi icon on the control panel to open iwgtk ( if you have it ) or bind a key in ~/.config/sway/config

Install ```blueman``` for visual bluetooth setup

- Press the bluetooth icon on the control panel to open blueman ( if you have it ) or bind a key in ~/.config/sway/config

Install ```google-chrome``` or your favorite browser

- Press WIN+SHIFT+ENTER to open it or edit ~/.config/sway/config to modify the browser or the bindings

## Part Five - Install zsh with autosuggestions and autostart sway on login ##

Install ```zsh``` and ```zsh-autosuggestions``` and ```dbus```

If your distro doesn't have ```dbus```, install it and enable it as a service.

Change shell to zsh :

```
chsh -s /bin/zsh
```

Now zsh will setup XDG_SESSION_DIR and start sway automatically as a dbus session on the default terminal ( sway as a dbus session is needed for pipewire and other programs ). It will also remember every command you typed and offers command completion which is the best thing in terminals. zsh-autosuggestions location may differ on different distros, edit ~/.zshrc with the correct location if error emerges.

## Part Six - Pipewire, Wireplumber and xdg-dekstop-portal-wlr ##

If you want screen sharing under sway/wayland you will need ```pipewire``` with ```wireplumber``` and ```xdg-desktop-portal-wlr```.
You may also have to install ```pipewire-pulse``` and ```libspa-bluetooth``` packages for bluetooth audio.
If you use a non-systemd distribution you have to start these manually, in this case uncomment the autostart parts at the bottom of ~/.config/sway/config

For screen sharing in chromium/google chrome set preferred ozone platform to wayland under chrome://flags.

How to do it on Void Linux :
  
```
sudo xbps-install -y pipewire libspa-bluetooth xdg-desktop-portal-wlr
sudo usermod -a $USER -G bluetooth
sudo ln -s /etc/sv/bluetoothd /var/service
mkdir -p /etc/pipewire/pipewire.conf.d
ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

// uncomment these lines in ~/.config/sway/config
exec pipewire
exec /usr/libexec/xdg-desktop-portal-wlr -r
exec sleep 1 && /usr/libexec/xdg-desktop-portal -r
```

How to do it on Debian Bookworm :
  
```
sudo apt-get install pipewire-audio xdg-desktop-portal-wlr

// uncomment these lines in ~/.config/sway/config
exec /usr/libexec/xdg-desktop-portal-wlr -r
exec sleep 1 && /usr/libexec/xdg-desktop-portal -r
```

## Part Seven - Fine tune the looks of SwayOS ##

Set the default fonts and font sizes for GTK applications with ```gnome-tweaks```, use Ubuntu font since it is the default for SwayOS

Set dark mode for GTK 4 apps by typing ```gsettings set org.gnome.desktop.interface color-scheme prefer-dark```   
Set dark mode for GTK 3 apps ( chromium ) by typing 
```
mkdir ~/.config/gtk-3.0
echo '[Settings]\ngtk-application-prefer-dark-theme=1' > ~/.config/gtk-3.0/settings.ini
```  

Set font sizes according to your display size and resolution for foot, sway and swaybar, if your screen res is too high/low

If you want other input sources/keymaps for other languages, edit ~/.config/sway/config and uncomment/edit the input part at the top.

## Part Eight - Distro specific notes ##

**Void Linux**

To enable shutdown/reboot/suspend present in wcp-void.sh 

```
sudo echo "$USER ALL=NOPASSWD:/sbin/reboot,/sbin/poweroff,/sbin/zzz" | sudo tee -a /etc/sudoers
```

Clean package cache and remove orphaned packages and kernels

```
sudo xbps-remove -yO
sudo xbps-remove -yo
sudo vkpurge rm all
```

Disable beeping

```
echo 'blacklist pcspkr' | sudo tee -a /etc/modprobe.d/blacklist.conf
```

## Q&A ##

- Why is it named SwayOS? This is just a config/program collection on other OS's
- True, but SwayDesktop sounds lame and generic

- Where are the installer scripts from 2.0 and 1.0?
- No time & energy to maintain those. Also this helps understanding Desktop/OS internals
