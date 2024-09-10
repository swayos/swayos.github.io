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

Install sway and the basic utilities first with your package manager

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

3. Installing Sway Overview

Clone and build
Press CMD+C to reload sway config and now you can summon sway overview by long pressing CMD+1 or right clicking on the status bar
If font is too small or want an other font change it under ~/.conifg/sov/config

3. Installing Wayland Control Panel

Clone and build
Press CMD+C to reload sway config and now you can summon the control panel by left clicking on the status bar
If font is too small or want an other font change it under ~/.conifg/wcp/config

4. Installing zsh

Install zsh and zsh-autosuggestions
Change shell to zsh :

```
chsh -S zsh
```

2. More utilities

```
grim
slurp
wob
brightnessctl
pavuctl
wdisplays
system-config-printer
```

5. Install iwd and iwgtk for smooth wifi experience.
Open iwgtk by CMD+SPACE and typing iwgtk
or open Control Panel and click on wifi

5. Install blueman for bluetooth
Open

5. Install browser, update MOD+SHIFT+RETURN shortcut in ~/.config/sway/config to open it ( by default it is google chrome )

4. Edit ~/.config/sway/status.sh to modify your status bar

5. Download gnome tweaks, set default font to UBuntu, set default font size, set default cursor

gsettings set cursor
gsettings set font size
[Settings]
gtk-application-prefer-dark-theme=1

5. Set font sizes according to your display size and resolution for foot, sway and waybar

6. Set preferred ozone platform to Wayland in Google Chrome/Chromium for 120 Hz scrolling ( if display is capable )
