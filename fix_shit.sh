#!/bin/bash
# I am do stupid to autoexecute all this on device change to now its a script with a hotkey to fix shit
${HOME}.config/polybar/launch.sh &>/dev/null
xinput --map-to-output "ELAN2514:00 04F3:2817" eDP-1
xinput --map-to-output "ELAN2514:00 04F3:2817 Stylus Pen (0)" eDP-1
xinput --map-to-output "ELAN2514:00 04F3:2817 Stylus Eraser (0)" eDP-1
xset r rate 235 60
