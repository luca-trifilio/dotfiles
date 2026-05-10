#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"

VOLUME="${INFO:-$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)}"
[ -z "$VOLUME" ] && exit 0

case $VOLUME in
  [6-9][0-9]|100) ICON="󰕾" ;;
  [3-5][0-9])     ICON="󰖀" ;;
  [1-9]|[1-2][0-9]) ICON="󰕿" ;;
  *)              ICON="󰖁" ;;
esac

if [ "$VOLUME" -gt 85 ] 2>/dev/null; then COLOR=$VOLUME_ICON_COLOR_RED
elif [ "$VOLUME" -gt 60 ] 2>/dev/null; then COLOR=$VOLUME_ICON_COLOR_ORANGE
elif [ "$VOLUME" -gt 30 ] 2>/dev/null; then COLOR=$VOLUME_ICON_COLOR_YELLOW
else COLOR=$VOLUME_ICON_COLOR_GREEN
fi

sketchybar --set volume_icon icon="$ICON" icon.color="$COLOR" label="${VOLUME}%"
