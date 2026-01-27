#!/bin/bash

DISK_PERCENTAGE=$( df -hT | awk '{print $6f}'| grep -v Use% | cut -d "%" -f1
)
ALL=$(df -hT | awk '{print $7f,$6f}'| grep -v Mounted)

while IFS= read -r line;
do
    current=$(echo "$line" | awk '{print $2}' | cut -d "%" -f1)
    if [ "$current" -ge 2 ]; then
        echo "More usage on the $line"
    fi
done <<< "$ALL"