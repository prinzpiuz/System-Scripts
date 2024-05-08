#!/bin/bash

# This script is make a screen shots folder if not exists, so that all screenshots will record on tmp folder and will be deleted after restarts

readonly DIRECTORY=/tmp/ScreenShots 

if [ ! -d "$DIRECTORY" ]; then
   mkdir -p $DIRECTORY
fi