#!/bin/bash
# sets the backlight to the percent value of first argument.
# Deprecated should just get xbacklight to work
# watch out as this has no sanity checks while directly writing to /sys
if [[ $# -eq 0 ]]; then
	echo "Missing operand!"
	echo "input a percent value as either absolute or use +/- to change relative"
	exit
fi
old=$(cat /sys/class/backlight/intel_backlight/brightness)
max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
if [[ ${1:0:1} =~ [+-] ]]; then
	new=$((old + max * $1 /100))
else
	new=$((max * $1 / 100))
fi
if [[ $new -lt $((max / 100)) ]]; then
	new=$((max / 100))
fi
echo $new > /sys/class/backlight/intel_backlight/brightness
