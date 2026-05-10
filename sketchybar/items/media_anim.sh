#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"

sketchybar --add item media_anim right \
           --set media_anim update_freq=1 \
                            drawing=off \
                            label.drawing=off \
                            icon.font="$FONT:Bold:10.0" \
                            icon.color=$RED \
                            icon.y_offset=-1 \
                            background.drawing=off \
                            script="$PLUGIN_DIR/media_anim.sh"
