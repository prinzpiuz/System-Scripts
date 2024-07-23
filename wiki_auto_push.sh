#!/bin/bash

#this is a program to automaticaly push system wiki
#depends on inotify
cd /home/prinzpiuz/prinzpiuz-notes/prinzpiuz-notes/wiki/ || exit 
/usr/bin/inotifywait -q -m -e CLOSE_WRITE --format="git commit -m 'auto commit:$(date)' %w && git push origin master" /home/prinzpiuz/prinzpiuz-notes/prinzpiuz-notes/wiki/System‐configuration.md | bash
