#!/bin/bash
# The Sway configuration file in ~/.config/sway/config calls this script.
# You should see changes to the status bar after saving this script.
# If not, do "killall swaybar" and $mod+Shift+c to reload the configuration.

cpu_formatted=$(uptime | awk '{print $8}' | cut -d "," -f 1)
mem_formatted=$(free -m | awk 'NR==2{printf "%.0f\n", $3*100/$2 }')
disk_formatted=$(df -h | awk '$NF=="/"{printf "%s\n", $5}' )
date_formatted=$(date "+%a %F %H:%M")
lcd_formatted=$(($(brightnessctl g) * 100 / $(brightnessctl m)))
bat_formatted=$(cat /sys/class/power_supply/BAT0/capacity)
vol_formatted=$(pamixer --get-volume)

echo "cpu $cpu_formatted / mem $mem_formatted% / ssd $disk_formatted / bat $bat_formatted% / lcd $lcd_formatted% / vol $vol_formatted%    $date_formatted "
