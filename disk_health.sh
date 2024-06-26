#!/bin/bash
function drives_csv {
	declare -A drive_values
	for d in $(smartctl --scan -d scsi | cut -d' ' -f1); do
		drive_values["-Drive-----------------"]="${drive_values[-Drive-----------------]},$d"
		for l in $(smartctl -A "$d" | grep ATTRIBUTE_NAME -A30 | grep -v ATTRIBUTE_NAME | column -H1,3,4,5,6,7,8,9,11,12,13,14,15 -t -o, | sed 's/ //g'); do
			key=$(echo $l | cut -d',' -f1)
			value=$(echo $l | cut -d',' -f2)
			existing=${drive_values["$key"]}
			drive_values["${key}"]="${existing},${value}"
		done
	done
	for key in "${!drive_values[@]}"; do
		echo "${key}${drive_values[$key]}"
	done | sort
}
drives_csv | column -s, -t