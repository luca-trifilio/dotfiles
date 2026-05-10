#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"
source "$CONFIG_DIR/helpers/icon_map_fn.sh"

sketchybar --add event aerospace_workspace_change
sketchybar --add event window_detected

for sid in $(aerospace list-workspaces --all); do
  sketchybar --add item space.$sid left \
             --subscribe space.$sid aerospace_workspace_change front_app_switched window_detected \
             --set space.$sid \
                  icon="$sid" \
                  icon.font="$FONT:Bold:14.0" \
                  icon.padding_left=10 \
                  icon.padding_right=0 \
                  icon.color=$WORKSPACE_ICON_COLOR \
                  icon.highlight=false \
                  icon.highlight_color=$WORKSPACE_ICON_HIGHLIGHT_COLOR \
                  label.font="sketchybar-app-font:Regular:14.0" \
                  label.padding_right=20 \
                  label.color=$WORKSPACE_LABEL_COLOR \
                  label.highlight=false \
                  label.highlight_color=$WORKSPACE_LABEL_HIGHLIGHT_COLOR \
                  label.y_offset=-1 \
                  background.drawing=on \
                  background.color=$WORKSPACE_ITEM_COLOR \
                  background.border_color=$WORKSPACE_ITEM_BORDER_COLOR \
                  background.border_width=2 \
                  background.corner_radius=$ITEM_CORNER_RADIUS \
                  background.height=$ITEM_HEIGHT \
                  click_script="aerospace workspace $sid" \
                  script="$PLUGIN_DIR/space_windows.sh"

  # Initial population of icons
  apps=$(aerospace list-windows --workspace "$sid" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
  icon_strip=" "
  if [ -n "$apps" ]; then
    while read -r app; do
      icon_map "$app"
      icon_strip+=" $icon_result"
    done <<< "$apps"
  else
    icon_strip=" —"
  fi
  sketchybar --set space.$sid label="$icon_strip"
done
