# SwayOS

SwayOS is a productivity-oriented minimalist and super elegant desktop layer over unix-like operating systems that can be installed as a standalone OS also. It is suitable for office, internet, system administration and programming work out of the box.

![screenshot](pics/swayos.png)
![screenshot](pics/swayos-busy.png)

**Donations**  
paypal : [https://paypal.me/milgra](https://paypal.me/milgra)  
patreon : [https://www.patreon.com/milgra](https://www.patreon.com/milgra)  
bitcoin : 37cSZoyQckihNvy939AgwBNCiutUVN82du      
**Discussions/Issues/Feature requests**  
[https://github.com/swayos/swayos.github.io/discussions](https://github.com/swayos/swayos.github.io/discussions)  
**Source**  
[https://github.com/swayos/swayos.github.io](https://github.com/swayos/swayos.github.io)

## How does it help productivity?

The more time you can spend working on your task the more productivity you can achieve. The more time you have to spend using the OS, dealing with windows, looking for things, clicking in submenus the less productivity you can achieve.

SwayOS shows all necessary information at a glance : if you keep WIN + numbers pushed, you see all workspaces, all windows in the workspaces, all commands in the terminals, page titles in the browser, you see your computers hardware status in the center of the status bar and you can also reach all hardware settings with one click and all regularly used softwares with one click. It's just unbelievable! :)

SwayOS is workspace oriented. Before opening an application you have to select a workspace where you want to open it. You can move the application to an other workspace any time if it fits your workflow better. It's like a multi-monitor setup but with one monitor!

SwayOS handles window placement automatically, windows always take the maximum space available, they don't even have title bars, close, maximize buttons. You can close and resize them with key combinations.

For example if you want to open three terminal windows in workspace three, you switch to workspace three by pressing WIN + 3 and press WIN + ENTER three times ( that is the shortcut for the terminal ) or press the terminal icon three times ( in the status bar ) or press WIN + SPACE and select the terminal you want to start, three times.
If you want to close one terminal you move your mouse over it and press WIN + SHIFT + Q.
If you want to move one terminal window to workspace four you move your mouse over it and press WIN + SHIFT + 4.
These are all the shortcuts you have to know.

SwayOS tries to be a distraction free OS. So there is no notification system installed by default altough you can install one any time, you also have to manage software updates manually by opening the app store and check for available updates.

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

**For beginners/For people with no time**

Download the latest ISO :

[download from my homepage](https://milgra.com/downloads/swayos-2022.05.12-x86_64.iso)  
[download from my google drive](https://drive.google.com/drive/folders/1QN9WZD2Ij2WE7QJ7IpHQDpHaP7rSk4Fs?usp=sharing)  

Burn it to a pendrive/etc and start your machine up with it. Installer will start automagically.

_Note : it is a minimal-configuration quick installer, options are pretty limited_

**For advanced users/For people with more time**

Install your own desired OS or create a new user on your current OS, log in and type

```
Arch :
curl -O https://swayos.github.io/setup
bash setup

Debian :
wget https://swayos.github.io/setup
bash setup

FreeBSD
curl or wget https://swayos.github.io/setup
bash setup
```

Feel free to add support for your OS based on setup-arch.sh and creating a merge request

**For superhackers/For people with plenty of time**

Install all packages present in pacs/swayos and pacs/aur files. ( Package names on your OS/Distribution may differ and you may have to compile them manually. ) Copy everything under "home" to your home folder, copy all fonts under "fonts" to your fonts folder. Start services if needed. ( iwd, bluetooth, cups )

**Optional Post-installation todos**

- setup pipewire support in chrome, go to url chrome://flags/#enable-webrtc-pipewire-capturer
- set google chrome's appereance to GTK+ so it will use the dark theme
- set locale to your language ( will be added to installer later )
- set your keyboard language in sway config ( will be added to installer later )
- remove export WLR_NO_HARDWARE_CURSORS=1 from .zshrc ( will be added to installer later )
- remove swayos_setup_* log files from your home directory
- don't forget to check for updates regularly!

## Currently supported OS's and notes

Linux

- Arch ( Actual )
  - feature complete

- Debian 12 ( Bookworm )  
  - pamac is not available so gnome-software is used  
  - have to fix the magnifier icon in font-awesome

- FreeBSD 13
  - no gui software store
  - no google chrome, chromium is used
  - no iwgtk and no wifi selector
  - no blueman and no bluetooth selector

## UI Structure of SwayOS

SwayOS's UI has two parts : the status bar ( on top by default ) and the window area under the status bar.
The status bar has the following sections from left to right : workspace numbers block ( indicators ) , hardware status block ( in the center by default ), quick launch icons block, hardware settings icon block and clock/calendar on the right.

**Icons from right to left :**

 shutdown  
 activity monitor  
 app store/software updates  
 display setup  
 volume control  
 bluetooth control  
 wifi setup  

 printer setup  
 libreoffice  
 google chrome  
 file manager  
 terminal  
 application launcher

## Usage of SwayOS ##

By default you have these applications :

- Google Chrome for internet
- LibreOffice for office work
- Nautilus as file manager
- Foot for terminal

You open apps by pressing WIN key + SPACE or by clicking on the quick launch icons.
If you need anything else open the app store by clicking on the shield icon on the right side of the status bar, search for it and click on the green download button.

Recommended multimedia applications :

GIMP for image editing ( Photoshop replacement )  
Inkscape for vector graphics ( Illustrator replacement )  
Natron for video post processing ( After Effects replacement )  
Davinci Resolve for video editing ( Premiere Pro replacement )  
Shotcut for simpler video editing  
Blender for 3D modelling and rendering ( 3DSMax/Cinema 4D replacement )  
Steam for gaming. Enable proton in its settings and you can play 95% of all windows games  

Recommended system tools :

hardinfo for hardware information  
tlp for energy saving features  
nvidia for nvidia/nvidia-intel hybrid gpus  
ati for ati/ati-intel hybrud gpus  
noisetorch for noise cancellation during meetings  
qemu and virt-manager for virtualization  
swaync for notification center  
imv for fast image viewing  

You should create a Documents and a Downloads folder under your home directory and save work and downloaded files there.
The file manager opens in floating mode so you can drag and drop files on your applications if needed if you open the file managaer in the same workspace.

If you don't have multimedia keys the you can change volume and display brightness by going over the lcd and vol entries in the center of the status bar and do a scroll over them.

## Troubleshooting ##

If you have questions/problems regarding the design & workflow & component selection of SwayOS, ask it [here](https://github.com/swayos/swayos.github.io/discussions)
If you have any other problems then it's probably related to your OS's discussion forums. If you are using the installer ISO, it's [Arch Linux Forums](https://bbs.archlinux.org/), if you are using something else then go to the proper discussion forums.

## Components and how to configure them

- **sway wm** : Sway Window Manager, config file is /home/youruser/.config/sway/config , learn more about it's configuration [here](https://github.com/swaywm/sway/wiki)
- **waybar** : Status Bar Manager, config file is  /home/youruser/.config/waybar/config , learn more about it's config [here](https://github.com/Alexays/Waybar/wiki)
- **wofi** : Application launcher, config file is /home/youruser/.config/wofi/config, visible when pressing WIN + SPACE
- **wob** : Volume/Brightness overlay bar, visible when you change volumes with the dedicated keys on your laptop, configurable in sway config
- **sov** : Workspaces overview layer, visible when you press the WIN + numbers for a longer period, config file is /home/youruser/.config/sway-overview/config
- **swaylock** : Screen locker, locks automatically or lock manually from the shutdown menu, set up in sway wm's config
- **swayidle** : Idle time handler, locks screen automatically after 10 minuter, set up in sway wm's config
- **grim** : Screen capture utility, activated with WIN + PRTSCR, set up ins sway wm's config
- **slurp** : Screen region capture utility, activated with WIN + SHIFT + PRTSCR, set up ins sway wm's config
- **iwgtk** : wifi selector app, no config file
- **blueman** : bluetooth selector app, no config file
- **brightnessctl** : lcd brightness control, set up ins sway wm's config
- **terminus-font** : default font for desktop and terminal
- **ubuntu-font** : default font for applications
- **pipewire** : audio/video server, needed for chrome desktop sharing and faster bluetooth audio
- **pamac-manager** : app store/system updater
- **pavucontrol** : volume control ui
- **polkit-gnome** : GUI Authentication agent
- **wdisplays** : display manager
- **wlogout** : logout manager
- **zsh** : shell
- **gnome-system-monitor** : activity/process monitor ui
- **qt5-style-plugings** : to make qt apps look like gtk2 apps
- **system-config-printer** : printer manager

## Frequently Asked Questions

- **How to change display brightness**  
with brightness keys  
by moving mouse over lcd pecentage in status bar and scroll

- **How to change volume**  
with volume keys  
by moving mouse over volume percentage in status bar and scroll  
by clicking on the audio icon in the status bar  

- **How to mount external usb devices?**  
Just click on the file manager icon in the status bar, it will auto-mount connected usb drives.

- **How to add new icons/applications to the quick launch menu?**  
Edit waybar config at /home/youruser/.config/waybar/config , add new custom blocks for your desired applications, get symbols from (fontawesome)[https://fontawesome.com/search?s=solid%2Cbrands].

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

- **Why google chrome instead of chromium?**  
SwayOS's intention is to create a user-friendly tiling window manager experience for less experienced users/switchers, and for that Libreoffice and Google sync enabled chrome is mandatory, spotify and netflix are also a reason.

- **Where can I see all my installed applciations?**  
Launch app store, under Installed you see all programs your system have and among them there are your desktop apps.

- **How to make a specific program open in a floating window always?**  
Enable the program to be a floating in sway config.

- **Chrome says its out of date**  
Open the app store, open preferences, go to third-party, Enable AUR support and enable check for updates

## Changelog ##

[Go to changelog](docs/CHANGELOG.md)

## Contributing ##

[Go to contribution](docs/CONTRIB.md)

## Todo ##

[Go to todo](docs/TODO.md)
