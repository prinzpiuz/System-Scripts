#!/bin/bash
xrandr --output DP-1 --off
sleep 1
xrandr --output DP-1 --mode 3840x2160 --rate 30 --primary
feh --bg-fill /home/prinzpiuz/solarSystem4k.png
