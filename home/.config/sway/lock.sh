#!/bin/bash

swayidle -w timeout 5 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' &
swaylock
pkill --newest swayidle
