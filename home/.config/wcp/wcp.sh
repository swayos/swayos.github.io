#!/usr/bin/env bash

PIPE_IN="/tmp/wcp"

# reset fifo in case it already exists and used by an older process
rm -f $PIPE_IN
mkfifo $PIPE_IN
exec 3<>$PIPE_IN

# update sliders and labels in ui
function update()
{
    echo "WCP.SH Getting volume"
    vol=$(pamixer --get-volume | awk '{print $1;}')
    volrat=$(echo "scale=2 ; $vol / 100" | bc)
    echo "WCP.SH Volume Ratio $volrat"

    echo "WCP.SH Getting brightness"
    lcdact=$(brightnessctl g)
    lcdmax=$(brightnessctl m)
    lcdrat=$(echo "scale=2 ; $lcdact / $lcdmax" | bc)
    echo "WCP.SH Brightness ratio $lcdrat"

    echo "WCP.SH Getting bluetooth device"

    btdevice=$(bluetoothctl devices | cut -f2 -d' ' | while read uuid; do bluetoothctl info $uuid; done|grep -e "Device\|Connected\|Name")
    if [[ $? -eq 1 ]];
    then
	btdevice="No_devices_found"
    fi
    echo "WCP.SH Bluetooth device $btdevice $?"

    echo "WCP.SH Getting wifi network"
    network=$(iwctl station wlo1 show | sed -n 7p | awk '{print $NF}')
    echo "WCP.SH Wifi network $network"

    echo "WCP.SH Getting printer"
    printer=$(lpstat -e)
    if [[ $? -eq 127 ]];
    then
       printer="No_printers_found"
    fi
    echo "WCP.SH Printer $printer $?"

    echo "WCP.SH Getting layout"
    layout=$(swaymsg -t get_inputs | jq '.[0].xkb_active_layout_name' | sed 's/^.//;s/.$//')
    echo "WCP.SH Layout $layout"

    echo "set ratio div volslider value $volrat" >&3
    echo "set ratio div lcdslider value $lcdrat" >&3
    echo "set text div btoothlabel value $btdevice" >&3
    echo "set text div wifilabel value $network" >&3
    echo "set text div printerlabel value ${printer// /_}" >&3
    echo "set text div keyboardlabel value ${layout// /_}" >&3
}

kuid -v <&3 | while IFS= read -r line; do                     # start kuid with file descriptor 3 as input and pipe its output to a reader

    echo "KUID:" $line
    words=($line)
    if [ ${words[0]} = "event" ]                              # analyze words in kuid output
    then

	if [ ${words[1]} = "init" ]                           # init event arrived
	then

	    echo "WCP.SH Creating layer"
	    echo "create layer width 290 height 250 anchor rt margin 5" >&3
	    echo "load html src ~/.config/wcp/res/main.html" >&3
	    echo "WCP.SH Layer created"
	    
	    update                                            # update sliders and labels

	elif [ ${words[1]} = "update" ]
	then

	    update	                                      # update sliders and labels

	# slider events
	elif [ ${words[1]} == "ratio" ]
	then
	    if [ ${words[3]} == "volslider" ]                 # volume slider moved
	    then

		echo "WCP.SH Setting volume"
		vol=${words[7]}
		res=$(pactl set-sink-volume @DEFAULT_SINK@ $vol%) # pactl
		echo "WCP.SH Volume set"

	    elif [ ${words[3]} == "lcdslider" ]               # lcd slider moved
	    then

		echo "WCP.SH Setting brightness"
		lcd=${words[7]}
		res=$(brightnessctl set $lcd%)                # brightnessctl
		echo "WCP.SH Brightness set"

	    fi

	# button events
	elif [ ${words[1]} == "state" ]
	then
	    if [ ${words[3]} == "mutebtn" ]                   # volume button pressed
	    then

		swaymsg exec pavucontrol

	    elif [ ${words[3]} == "displaybtn" ]              # display button pressed
	    then

		swaymsg exec wdisplays

	    elif [ ${words[3]} == "wifibtn" ] ||
		 [ ${words[3]} == "wifilabelback" ]           # wifi button pressed
	    then

		swaymsg exec iwgtk
      
	    elif [ ${words[3]} == "bluetoothbtn" ] ||
		 [ ${words[3]} == "btoothlabelbck" ]          # bluetooth button pressed
	    then                                              

		swaymsg exec blueman-manager

	    elif [ ${words[3]} == "printerbtn" ] ||
		 [ ${words[3]} == "printerlabelback" ]           # wifi button pressed
	    then

		swaymsg exec system-config-printer

	    elif [ ${words[3]} == "lockbtn" ]                 # lock button pressed
	    then

		swaymsg exec swaylock

	    elif [ ${words[3]} == "logoutbtn" ]               # logout button pressed
	    then

		sway exit

	    elif [ ${words[3]} == "suspendbtn" ]              # suspend button pressed
	    then

		sudo /sbin/zzz
	
	    elif [ ${words[3]} == "rebootbtn" ]               # reboot button pressed
	    then
		
		sudo /sbin/reboot

	    elif [ ${words[3]} == "shutdownbtn" ]             # shutdown button pressed
 	    then

		sudo /sbin/poweroff

	    fi
	fi
    fi
done
