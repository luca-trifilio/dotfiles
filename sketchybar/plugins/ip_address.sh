#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"

IP_ADDRESS=$(scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1)
IS_VPN=$(scutil --nwi | grep -E 'utun|ppp' | awk '{ print $1 }')

if [[ $IS_VPN != "" ]]; then
  ICON=""
  COLOR=$IP_ICON_COLOR_VPN
elif [[ $IP_ADDRESS != "" ]]; then
  ICON="󰖩"
  COLOR=$IP_ICON_COLOR_WIFI
else
  ICON=""
  COLOR=$IP_ICON_COLOR_OFFLINE
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR"
