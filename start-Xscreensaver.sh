#!/bin/bash

# A workaround to implement lock screen with flipclock screen
# https://forum.manjaro.org/t/use-another-lockscreen-with-xscreensaver-is-it-possible/35084

xscreensaver-command -activate
xscreensaver-command -watch | while read -r line
do
    if [[ ${line::1} == U ]]
    then
        killall xscreensaver-command
        i3lock -i /home/prinzpiuz/debian_logo4k.png
    fi
done