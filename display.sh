#!/bin/bash
# display.sh - i3 + dmenu display switcher
# Office: laptop HDMI direct.  Home: Thunderbolt dock.

INTERNAL_OUTPUT="eDP-1"
WALLPAPER="$HOME/Pictures/wallpaper.jpg"
DMENU_FONT="DejaVu Sans Mono-14"

DPI_EXTERNAL=144 # 27" 4K
DPI_INTERNAL=96  # adjust to taste for the laptop panel

# Detect whichever external output is actually connected.
# Matches HDMI-1, DP-1, DVI-1, VGA-1 etc. and ignores "disconnected".
EXTERNAL_OUTPUT=$(xrandr | grep -E '^(HDMI|DP|DVI|VGA)[^ ]* connected' |
        head -n1 | cut -d' ' -f1)

choices="Laptop\nExternal 4K30 (sharp)\nExternal 1440p60 (smooth)\nDual\nClone"
chosen=$(echo -e "$choices" | dmenu -i -fn "$DMENU_FONT")

set_dpi() {
        echo "Xft.dpi: $1" | xrdb -merge
}

refresh_desktop() {
        [ -f "$WALLPAPER" ] && feh --bg-fill "$WALLPAPER"
        i3-msg restart >/dev/null 2>&1
}

if [ -z "$EXTERNAL_OUTPUT" ] && [ "$chosen" != "Laptop" ]; then
        notify-send "display.sh" "No external display detected"
        exit 1
fi

case "$chosen" in
"External 4K30 (sharp)")
        xrandr --output "$INTERNAL_OUTPUT" --off \
                --output "$EXTERNAL_OUTPUT" --mode 3840x2160 --rate 30 --primary
        set_dpi $DPI_EXTERNAL
        ;;

"External 1440p60 (smooth)")
        xrandr --output "$INTERNAL_OUTPUT" --off \
                --output "$EXTERNAL_OUTPUT" --mode 2560x1440 --rate 60 --primary
        set_dpi 96
        ;;

Laptop)
        xrandr --output "$INTERNAL_OUTPUT" --auto --primary \
                --output "$EXTERNAL_OUTPUT" --off
        set_dpi $DPI_INTERNAL
        ;;

Clone)
        xrandr --output "$INTERNAL_OUTPUT" --auto \
                --output "$EXTERNAL_OUTPUT" --auto --same-as "$INTERNAL_OUTPUT"
        set_dpi $DPI_INTERNAL
        ;;

Dual)
        xrandr --output "$INTERNAL_OUTPUT" --auto \
                --output "$EXTERNAL_OUTPUT" --auto --right-of "$INTERNAL_OUTPUT" --primary
        set_dpi $DPI_INTERNAL
        ;;

*) exit 0 ;;
esac

refresh_desktop
