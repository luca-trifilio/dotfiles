#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"

sketchybar --add item ip_address right \
           --subscribe ip_address network_change system_woke wifi_change \
           --set ip_address update_freq=60 \
                            icon.color=$IP_ICON_COLOR_WIFI \
                            label.drawing=off \
                            background.drawing=on \
                            background.color=$ITEM_BG_COLOR \
                            background.border_color=$ITEM_BORDER_COLOR \
                            background.border_width=2 \
                            click_script="open 'x-apple.systempreferences:com.apple.Network-Settings.extension'" \
                            script="$PLUGIN_DIR/ip_address.sh"
