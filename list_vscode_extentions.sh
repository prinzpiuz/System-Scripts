#!/bin/bash

EXTENSIONS=$(code --list-extensions)
mapfile -t StringArray <<< "$EXTENSIONS"
for val in "${StringArray[@]}"; 
    do echo "$val"  | tr "." " "| awk '{print $2}' | tr "-" " " | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1'; 
done
