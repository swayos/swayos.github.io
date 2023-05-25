#!/bin/bash

if [ $# -eq 0 ]
then
    echo ""
else
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
	if [[ ${DISTRIB} = *"Void"* ]]; then
	    sudo /sbin/reboot
	else
	    swaymsg exec systemctl reboot
	fi
    fi
fi
