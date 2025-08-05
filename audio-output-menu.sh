#!/bin/bash

#This is supposed to work with pactl and demenu

# Get current default sink and card name
CURRENT_SINK=$(pactl info | grep 'Default Sink:' | awk -F': ' '{print $2}')
CARD_NAME=$(pactl list short cards | grep pci | awk '{print $2}')

# Switch profile first to make sure all sinks become active
if echo "$CURRENT_SINK" | grep -qi "hdmi"; then
    pactl set-card-profile "$CARD_NAME" output:analog-stereo || true
else
    pactl set-card-profile "$CARD_NAME" output:hdmi-stereo || true
fi

# Wait a moment for sinks to become active
sleep 0.5

MENU="dmenu -i "

# Create associative array to map descriptions to sink names
declare -A sink_map

# Get sink indexes
mapfile -t sinks < <(pactl list sinks short | awk '{print $1}')
menu_items=()

for sink_index in "${sinks[@]}"; do
  sink_block=$(pactl list sinks | awk -v idx="$sink_index" '
    $0 ~ "Sink #"idx {found=1}
    found && /Name:/ {name=$2}
    found && /Description:/ {desc = substr($0, index($0, $2)); print name; print desc; exit}
  ')

  sink_name=$(echo "$sink_block" | sed -n '1p')
  sink_desc=$(echo "$sink_block" | sed -n '2p')

  sink_map["$sink_desc"]="$sink_name"
  menu_items+=("$sink_desc")
done

# Show menu
choice=$(printf '%s\n' "${menu_items[@]}" | $MENU)

[ -z "$choice" ] && exit 1

sink_name="${sink_map[$choice]}"

# Set as default sink
pactl set-default-sink "$sink_name"

# Move all existing streams
pactl list short sink-inputs | while read -r stream; do
  stream_id=$(echo "$stream" | cut -f1)
  pactl move-sink-input "$stream_id" "$sink_name"
done

# Notify
dunstify "Audio Output Switched $choice"
