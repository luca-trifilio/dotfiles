#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"

sketchybar --add item volume_icon right \
           --set volume_icon update_freq=60 \
                             icon.color=$VOLUME_ICON_COLOR \
                             label.color=$VOLUME_LABEL_COLOR \
                             label.padding_right=4 \
                             background.drawing=on \
                             background.color=$ITEM_BG_COLOR \
                             background.border_color=$ITEM_BORDER_COLOR \
                             background.border_width=2 \
                             script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume_icon volume_change
