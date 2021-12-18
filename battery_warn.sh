#!/bin/bash
# small script to send notification on battery almost empty or full
current=$(cat /sys/class/power_supply/BAT0/capacity)
if [ "$current" -lt 10 ]
then
	notify-send "Die Battery ist eher leer. Sollte mal gelade werden"
elif [ "$current" -gt 90 ]
then
	notify-send "Reicht auch schon wieder mit dem laden"
fi
