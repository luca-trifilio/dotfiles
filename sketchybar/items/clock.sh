#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"

sketchybar --add item clock right \
           --set clock update_freq=10 \
                       icon="󰃭" \
                       icon.color=$CLOCK_ICON_COLOR \
                       label.color=$CLOCK_LABEL_COLOR \
                       background.drawing=on \
                       background.color=$ITEM_BG_COLOR \
                       background.border_color=$ITEM_BORDER_COLOR \
                       background.border_width=2 \
                       script="$PLUGIN_DIR/clock.sh"
