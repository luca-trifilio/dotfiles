#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo '\d+%' | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ -z "$PERCENTAGE" ]; then exit 0; fi

if [ -n "$CHARGING" ]; then
  ICON="󰂄"
  COLOR=$BATTERY_ICON_COLOR_GREEN
else
  case "$PERCENTAGE" in
    9[0-9]|100) ICON="󰁹" ;;
    [7-8][0-9]) ICON="󰂁" ;;
    [4-6][0-9]) ICON="󰁾" ;;
    [1-3][0-9]) ICON="󰁼" ;;
    *)          ICON="󰁺" ;;
  esac
  if [ "$PERCENTAGE" -gt 60 ]; then
    COLOR=$BATTERY_ICON_COLOR_GREEN
  elif [ "$PERCENTAGE" -gt 25 ]; then
    COLOR=$BATTERY_ICON_COLOR_YELLOW
  else
    COLOR=$BATTERY_ICON_COLOR_RED
  fi
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
