if [ $# -eq 0 ]
then
    echo ""
else
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
	if [[ ${DISTRIB} = *"Void"* ]]; then
	    sway exit
	else
	    swaymsg exec loginctl terminate-user $USER
	fi
    fi    
fi
