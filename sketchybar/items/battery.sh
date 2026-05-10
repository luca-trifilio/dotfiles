#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"

sketchybar --add item battery right \
           --subscribe battery system_woke power_source_change \
           --set battery update_freq=120 \
                         icon.color=$BATTERY_LABEL_COLOR \
                         label.color=$BATTERY_LABEL_COLOR \
                         background.drawing=on \
                         background.color=$ITEM_BG_COLOR \
                         background.border_color=$ITEM_BORDER_COLOR \
                         background.border_width=2 \
                         script="$PLUGIN_DIR/battery.sh"
