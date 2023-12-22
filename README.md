# SwayOS 2.0


SwayOS is a productivity-oriented minimalist and super elegant desktop layer for unix-like operating systems. It is a collection of configuration files, open source applications and open source applications created exclusively for SwayOS ( Sway Overview, Wayland Control Panel, Wayland Favorite List, Visual Music Player and MultiMedia File Manager ).

[<img src="pics/swayos.png" width="850">](pics/swayos.png)

## Description ##

SwayOS is a productivity-oriented, resource efficient and elegant desktop layer for unix-like operating systems. It uses a tiling window manager so you don't have to deal with minimizing/maximizing/moving windows any more. Windows are placed automatically and always open. To avoid crowdedness you place your windows onto workspaces.

**Discussions/Issues/Feature requests** : [https://github.com/swayos/swayos.github.io/discussions](https://github.com/swayos/swayos.github.io/discussions)  
**Source** : [https://github.com/swayos/swayos.github.io](https://github.com/swayos/swayos.github.io)

## Shortcuts ##

**WIN + numbers** : switch to workspace / open overview ( long press )  
**WIN + SPACE** : open application launcher  
**WIN + SHIFT + Q** : close focused window  
**WIN + SHIFT + numbers** : move focused window to workspace with given number  

## Additional shortcuts that make work easier

**WIN + arrows** : set focus to neighbouring windows  
**WIN + SHIFT + arrows** : move window to a new position inside the workspace  
**WIN + R** : resize mode, if there are more windows in a workspace you can press WIN + R, resize window with arrows, then press ESC  
**WIN + ENTER** : open a terminal  
**WIN + SHIFT + ENTER** : open browser  
**ALT + SPACE** : switch keyboard layout if there are more  
**WIN + PrtScr** : take screenshot  
**WIN + SHIFT + SPACE** : toggle/untoggle floating over a window

## Installation ##

SwayOS install scripts are available for Void Linux and Debian Linux ( >=12 ).
On other OS'es and distributions you have to install the needed programs yourself and copy everything to your home folder from home/.config, check out the void/debian installer script.

Installation on Void or Debian :

Start with a clean minimal install of any of these systems, with network connection. Then

```
wget -O https://swayos.github.io/setup
bash setup
```

**Optional Post-installation todos**

- set font sizes according to your display size and resolution for foot, sway and waybar
- add you own favorite apps to ~/.config/wfl/wfl.sh
- setup pipewire support in chrome to enabel screen sharing, go to url chrome://flags/#enable-webrtc-pipewire-capturer
- set google chrome's appereance to GTK+ so it will use the dark theme
- remove swayos_setup_* log files from your home directory

## UI Structure of SwayOS

SwayOS's UI has two parts : the status bar ( on top by default ) and the window area under the status bar.
The status bar has the following sections from left to right : workspace block ( indicators ) , hardware status block ( in the center by default ), clock and quick launch icons block.

## Usage of SwayOS ##

By default you have these applications :

- Google Chrome for internet
- LibreOffice for office work
- Nautilus as file manager
- Foot for terminal
- Visual Music Player for offline music
- MultiMedia File Manager for media/document viewing and managing
- Sway Overview for workspace overview panel
- Wayland Control Panel for system menu/control panel
- Wayland Favorite List for favorite applications panel
- Wayland Overlay Bar for volume/brightness indication

You open apps by pressing WIN key + SPACE or by selecting them from the favorites menu.

Recommended multimedia applications :

Photopea for Photoshop replacement ( www.photopea.com )
Inkscape for vector graphics ( Illustrator replacement )  
Natron for video post processing ( After Effects replacement )  
Davinci Resolve for video editing ( Premiere Pro replacement )  
Shotcut for simpler video editing  
Blender for 3D modelling and rendering ( 3DSMax/Cinema 4D replacement )  
Steam for gaming. Enable proton in its settings and you can play 95% of all windows games  

## Components

- **sway wm** : Sway Window Manager
- **waybar** : Status Bar Manager
- **wofi** : Application launcher
- **wob** : Wayland Overlay Bar, visible when you change volumes with the dedicated keys on your laptop
- **sov** : Sway Overview, visible when you press the WIN + numbers for a longer period or the overview icon in the top left corner
- **wcp** : Wayland Control Panel, visible when you click on the settings icon in the status bar
- **swaylock** : Sway Lock, locks automatically or lock manually from the shutdown menu
- **swayidle** : Sway IDle, locks screen automatically after 10 minuter
- **grim** : Screen capture utility, activated with WIN + PRTSCR
- **slurp** : Screen region capture utility, activated with WIN + SHIFT + PRTSCR
- **iwgtk** : wifi selector app
- **blueman** : bluetooth selector app
- **brightnessctl** : lcd brightness control
- **terminus-font** : default font for desktop and terminal
- **ubuntu-font** : default font for applications
- **pipewire** : audio/video server, needed for chrome desktop sharing and faster bluetooth audio
- **pavucontrol** : volume control ui
- **wdisplays** : display manager
- **zsh** : shell
- **system-config-printer** : printer manager
- **visual music player** : offline music/video player, parses files under ~/Music
- **multimedia file manager** : media/document file viewer/player/manager

## Frequently Asked Questions

- **How to change display brightness**  
with brightness keys  
by moving mouse over lcd pecentage in status bar and scroll

- **How to change volume**  
with volume keys  
by moving mouse over volume percentage in status bar and scroll  
by clicking on the audio icon in the status bar  

- **How to mounnt external usb devices?**  
Open nautilus from the favorites, it will auto-mount connected usb drives.

- **How to add multiple keyboard input sources?**  
Edit sway config, add

```
input " your wanted device id " {
    ...
    xkb_layout "us,hu"
    xkb_options "grp:alt_space_toggle"
    ...
}
```
- **How to make a specific program open in a floating window always?**  
Enable the program to be a floating in sway config.

## Donations

paypal : [https://paypal.me/milgra](https://paypal.me/milgra)  
patreon : [https://www.patreon.com/milgra](https://www.patreon.com/milgra)  
bitcoin : 37cSZoyQckihNvy939AgwBNCiutUVN82du      

## Known bugs

- sov should handle outputs pluggin in/out during session
- vmp and mmfm should use kuid like wcp and wfl for faster one person development