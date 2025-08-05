#!/bin/bash


MENU="dmenu -i"

# Create associative array to map descriptions to source names
declare -A source_map

# Get all sources that are inputs (skip monitors)
mapfile -t sources < <(pactl list short sources | grep -v 'monitor' | awk '{print $1}')

menu_items=()

for source_index in "${sources[@]}"; do
  source_info=$(pactl list sources | awk -v idx="$source_index" '
    $0 ~ "Source #"idx {found=1}
    found && /Name:/ {name=$2}
    found && /Description:/ {desc = substr($0, index($0, $2)); print name; print desc; exit}
  ')

  source_name=$(echo "$source_info" | sed -n '1p')
  source_desc=$(echo "$source_info" | sed -n '2p')

  source_map["$source_desc"]="$source_name"
  menu_items+=("$source_desc")
done

# Show menu
choice=$(printf '%s\n' "${menu_items[@]}" | $MENU)

[ -z "$choice" ] && exit 1

selected_source="${source_map[$choice]}"

# Set default source
pactl set-default-source "$selected_source"

# Notify
dunstify "Microphone Switched to $choice"
