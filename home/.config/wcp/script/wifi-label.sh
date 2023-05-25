if [ $# -eq 0 ]
then
# return actual volume when no parameter is received
    echo $(iwctl station wlp0s20f3 show | sed -n 7p | awk '{print $NF}')
fi
