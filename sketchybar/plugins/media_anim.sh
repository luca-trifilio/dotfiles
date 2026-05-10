#!/bin/bash

FRAMES=("▁▂▃" "▂▃▄" "▃▄▆" "▄▆█" "▆█▄" "█▄▂" "▄▂▁" "▂▁▂")
COUNT=${#FRAMES[@]}
IDX=$(( $(date +%S) % COUNT ))
sketchybar --set "$NAME" icon="${FRAMES[$IDX]}"
