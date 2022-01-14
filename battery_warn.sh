#!/bin/bash
# small script to send notification on battery almost empty or full
if [[ ! -d /sys/class/power_supply/BAT0 ]]; then
	echo ""
	exit 1
fi
current=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)
if [[ "$current" -le 10 ]] && [[ "$status" == "Discharging" ]]
then
	notify-send "Die Battery ist eher leer. Sollte mal gelade werden" \
		-u critical
elif [[ "$current" -ge 90 ]] && [[ "$status" == "Charging" ]]
then
	notify-send "Reicht auch schon wieder mit dem laden" \
		-u normal
fi
