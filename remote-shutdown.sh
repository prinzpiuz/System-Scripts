#!/bin/bash
set -e

REMOTE_USER="druv"
REMOTE_HOST="192.168.1.10"   # IP or hostname of remote machine
SSH_KEY="/root/.ssh/id_rsa"  # Path to SSH private key
LOG_FILE="/var/log/udev_shutdown_events.log"
DELAY=7200   # 2 hrs
FLAGFILE="/tmp/powerfail.lock"

echo "$(date) - Script started" >> $LOG_FILE

AC_STATE=$(/bin/cat /sys/class/power_supply/AC/online)
echo "$(date) - AC_STATE=$AC_STATE" >> $LOG_FILE

if [ "$AC_STATE" -eq 0 ]; then
    # Power failed
    if [ -f "$FLAGFILE" ]; then
        echo "$(date) - Shutdown countdown already running" >> $LOG_FILE
        exit 0
    fi

    echo "$(date) - Power failure detected. Waiting ${DELAY}s before shutdown..." >> $LOG_FILE
    echo $$ > "$FLAGFILE"

    # Wait for DELAY, checking every 30s if power is back
    for ((i=0; i<DELAY; i+=30)); do
        sleep 30
        AC_NOW=$(/bin/cat /sys/class/power_supply/AC/online)
        if [ "$AC_NOW" -eq 1 ]; then
            echo "$(date) - Power restored during delay. Cancelling shutdown." >> $LOG_FILE
            rm -f "$FLAGFILE"
            exit 0
        fi
    done

    # If we reach here → power did not return, shutdown remote
    echo "$(date) - No power after ${DELAY}s. Shutting down remote..." >> $LOG_FILE
    /usr/bin/ssh -i $SSH_KEY -o BatchMode=yes -o ConnectTimeout=10 \
        $REMOTE_USER@$REMOTE_HOST "sudo /sbin/shutdown -h now" >> $LOG_FILE 2>&1
    echo "$(date) - Shutdown command sent." >> $LOG_FILE
    rm -f "$FLAGFILE"

else
    # Power restored
    if [ -f "$FLAGFILE" ]; then
        echo "$(date) - Power restored before shutdown. Cancelling pending action." >> $LOG_FILE
        rm -f "$FLAGFILE"
    else
        echo "$(date) - Power restored. Nothing pending." >> $LOG_FILE
    fi
fi

exit 0
