#!/bin/bash

DISK_PERCENTAGE=$( df -hT | awk '{print $6f}'| grep -v Use% | cut -d "%" -f1
)
ALL=$(df -hT | awk '{print $7f,$6f}'| grep -v Mounted)

for IFS= read -r line;
do
    if [ $DISK_PERCENTAGE -ge 2 ]; then
        echo "More usage on the $line"
    fi
done <<< $ALL