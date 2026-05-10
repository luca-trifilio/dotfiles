#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"
source "$CONFIG_DIR/helpers/icon_map_fn.sh"

reload_workspace_icon() {
  if [ -z "$1" ]; then return; fi
  apps=$(aerospace list-windows --workspace "$1" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app; do
      icon_map "$app"
      icon_strip+=" $icon_result"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi
  sketchybar --animate sin 10 --set space.$1 label="$icon_strip"
}

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  if [ -z "$FOCUSED_WORKSPACE" ]; then exit 0; fi
  CURRENT_FOCUSED="$FOCUSED_WORKSPACE"
  CMD="sketchybar"
  for workspace in $(aerospace list-workspaces --all); do
    CMD="$CMD --set space.$workspace icon.highlight=false label.highlight=false background.color=$WORKSPACE_ITEM_COLOR background.border_color=$WORKSPACE_ITEM_BORDER_COLOR icon.color=$WORKSPACE_ICON_COLOR label.color=$WORKSPACE_LABEL_COLOR"
  done
  CMD="$CMD --set space.$CURRENT_FOCUSED icon.highlight=true label.highlight=true background.color=$WORKSPACE_ITEM_COLOR background.border_color=$WORKSPACE_ITEM_BORDER_HIGHLIGHT_COLOR icon.color=$WORKSPACE_ICON_HIGHLIGHT_COLOR label.color=$WORKSPACE_LABEL_HIGHLIGHT_COLOR"
  eval $CMD
  if [ -n "$PREV_WORKSPACE" ]; then
    reload_workspace_icon "$PREV_WORKSPACE"
  fi
  reload_workspace_icon "$CURRENT_FOCUSED"
fi

if [ "$SENDER" = "front_app_switched" ] || [ "$SENDER" = "window_detected" ]; then
  CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)
  reload_workspace_icon "$CURRENT_WORKSPACE"
fi
