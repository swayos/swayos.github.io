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
<br/>

**Part One - Install sway and the basic utilities first with your package manager**

<br/>

```
sway
swayidle
swaylock
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

<details>
  <summary>See how to do it on Void Linux</summary>
  
  ```
  sudo xpbs-install -Sy sway swayidle swaylock foot wofi ttf-ubuntu-font-family
  sudo xbps-install -Sy seatd
  sudo ln -s /etc/sv/seatd /var/service
  sudo usermod -a $USER -G _seatd
  git clone https://github.com/swayos/swayos.github.io
  cp -R swayos.github.io/home/.config ~/
  export XDG_RUNTIME_DIR=/tmp
  sway
  ```

</details>

<br/>

**Part Two - Installing Sway Overview**

<br/>

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

<details>
  <summary>See how to do it on Void Linux</summary>
  
  ```
  sudo xbps-install -y clang meson ninja cmake pkg-config
  sudo xbps-install -Sy libpng-devel freetype-devel libglvnd-devel glew-devel wayland-devel libxkbcommon-devel
  git clone https://github.com/milgra/sov
  cd sov
  meson setup build --buildtype=release
  ninja -C build
  sudo ninja -C build install
  ```

</details>

Press WIN+SHIFT+E to exit sway and start it again. Now you can summon sway overview by long pressing and holding CMD+1 or right clicking on the status bar. 
If fonts are too small or you want an other font change it under ~/.conifg/sov/html/main.css

<br/>

**Part Three - Installing Wayland Control Panel**

<br/>

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

<details>
  <summary>See how to do it on Void Linux</summary>
  
  ```
  git clone https://github.com/milgra/kuid
  cd kuid
  meson setup build --buildtype=release
  ninja -C build
  sudo ninja -C build install
  cd ..
  git clone https://github.com/milgra/wcp
  cd wcp
  mkdir ~/.config/wcp
  cp wcp-template.sh ~/.config/wcp/wcp.sh
  cp -R res ~/.config/wcp/
  cd ..
  ```

</details>

Press WIN+SHIFT+E to exit sway and start it again. Now you can summon wayland control panel by pressing WIN+P or by left clicking on the status bar ( The buttons/sliders won't work yet. )
If fonts are too small or you want an other font change it under ~/.conifg/wcp/res/main.css

<br/>

**Part Four - Make SwayOS comfortable & Wayland Control Panel usable**

<br/>

Install ```grim``` and ```slurp``` for making screenshots

- Press WIN+PRTSRC to put a screenshot or WIN+SHIFT+PRTSCR to put a region under ~/Downloads
Modify key bindings in ~/.config/sway/config

Install ```wob``` for volume/brightness indication

- Press volume/brightness keys on the keyboard to make wob visible.
Modify key bindings in ~/.config/sway/config

Install ```brightnessctl``` for controlling monitor brightness

- Press brighntess keys on the keyboard to modify brightness
Modify key bindings in ~/.config/sway/config

Install ```pavuctl``` for detailed audio control

- Press the volume icon on the control panel to open pavucontrol or bind a key in ~/.config/sway/config

Install ```wdisplays``` for display configuration

- Press the display icon on the control panel to open wdisplays or bind a key in ~/.config/sway/config

Install ```iwd``` and ```iwgtk``` for smooth wifi experience

- Press the wifi icon on the control panel to open iwgtk ( if you have it ) or bind a key in ~/.config/sway/config

Install ```blueman``` for visual bluetooth setup

- Press the bluetooth icon on the control panel to open blueman ( if you have it ) or bind a key in ~/.config/sway/config

Install ```google-chrome``` oe your favorite browser

- Press WIN+SHIFT+ENTER to open it or edit ~/.config/sway/config to modify the browser or the bindings

<details>
  <summary>See how to do it on Void Linux</summary>
  
  ```
  sudo xbps-install -y grim slurp wob brightnessctl pavucontrol wdisplays system-config-printer blueman
  ```

</details>

<br/>

**Part Five - Install zsh with autosuggestions and autostart sway on login**

<br/>

Install ```zsh``` and ```zsh-autosuggestions```

Copy swayos's zshrc to your home :

```
cp ~/swayos.github.io/home/.zshr ~/
```

Change shell to zsh :

```
chsh -s /bin/zsh
```

Now zsh will setup XDG_SESSION_DIR and start sway automatically on the default terminal. It will also remember every command you typed and offers command completion which is the best thing in terminals

<br/>

**Part Six - Fine tune the looks of SwayOS**

<br/>

Set the default fonts and font sizes for GTK applications with ```gnome-tweaks```, use Ubuntu font since it is the default for SwayOS

Set dark mode by typing ```gsettings set org.gnome.desktop.interface color-scheme prefer-dark```

Set default cursor theme in ~/.config/sway/config

Set font sizes according to your display size and resolution for foot, sway and waybar, if your screen res is too high/low

Set preferred ozone platform to Wayland in Google Chrome/Chromium for 120 Hz scrolling ( if display is capable )

<br/>

**Part Seven - Distro specific notes**

<br/>

**Void Linux**

Install desktio portal wlr for screen sharing in chrome/firefox

```
sudo xbps-instdall -y xdg-desktop-portal-wlr
```

Install pipewire with bluetooth support

```
sudo xbps-install -y pipewire pipewire blueman
sudo usermod -a $USER -G bluetooth
sudo ln -s /etc/sv/bluetoothd /var/service
```

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
