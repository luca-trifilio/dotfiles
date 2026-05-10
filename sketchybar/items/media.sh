#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"

# On the right side, last added = leftmost on screen.
# Desired display L→R: [art] [title/artist stacked]
# Add order: title+artist first (rightmost), art last (leftmost).

sketchybar \
  --add item media_artist right \
  --set media_artist \
    drawing=off \
    label.font="$FONT:Regular:9.0" \
    label.color=$SUBTEXT0 \
    label.max_chars=20 \
    label.padding_left=0 \
    label.padding_right=6 \
    label.y_offset=6 \
    label.width=0 \
    icon.drawing=off \
    background.drawing=off \
    padding_left=0 \
    padding_right=0 \
    script="$PLUGIN_DIR/media.sh" \
  --subscribe media_artist mouse.entered mouse.exited mouse.exited.global \
  \
  --add item media_title right \
  --set media_title \
    updates=on \
    update_freq=5 \
    drawing=off \
    label.font="$FONT:SemiBold:11.0" \
    label.color=$TEXT \
    label.max_chars=20 \
    label.padding_left=0 \
    label.padding_right=0 \
    label.y_offset=-5 \
    label.width=0 \
    icon.drawing=off \
    background.drawing=off \
    padding_left=0 \
    padding_right=0 \
    popup.horizontal=on \
    popup.align=right \
    popup.height=$ITEM_HEIGHT \
    popup.background.color=$SURFACE0 \
    popup.background.border_color=$SURFACE1 \
    popup.background.border_width=2 \
    popup.background.corner_radius=$ITEM_CORNER_RADIUS \
    script="$PLUGIN_DIR/media.sh" \
  --subscribe media_title media_change mouse.entered mouse.exited mouse.exited.global \
  \
  --add item media_art right \
  --set media_art \
    drawing=off \
    padding_left=6 \
    padding_right=2 \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=on \
    background.color=$TRANSPARENT \
    background.corner_radius=4 \
    background.height=$ITEM_HEIGHT \
    script="$PLUGIN_DIR/media.sh" \
  --subscribe media_art mouse.entered mouse.exited mouse.exited.global \
  \
  --add bracket media_bracket media_art media_title media_artist \
  --set media_bracket \
    background.drawing=on \
    background.color=$ITEM_BG_COLOR \
    background.border_color=$ITEM_BORDER_COLOR \
    background.border_width=2 \
    background.corner_radius=$ITEM_CORNER_RADIUS \
  \
  --add item media_prev popup.media_title \
  --set media_prev \
    icon="󰒮" \
    icon.font="$FONT:Bold:16.0" \
    icon.color=$TEXT \
    icon.padding_left=12 \
    icon.padding_right=6 \
    label.drawing=off \
    background.drawing=off \
    click_script="media-control previous-track" \
  \
  --add item media_playpause popup.media_title \
  --set media_playpause \
    icon="󰏤" \
    icon.font="$FONT:Bold:18.0" \
    icon.color=$PEACH \
    icon.padding_left=6 \
    icon.padding_right=6 \
    label.drawing=off \
    background.drawing=off \
    click_script="media-control toggle-play-pause" \
  \
  --add item media_next popup.media_title \
  --set media_next \
    icon="󰒭" \
    icon.font="$FONT:Bold:16.0" \
    icon.color=$TEXT \
    icon.padding_left=6 \
    icon.padding_right=12 \
    label.drawing=off \
    background.drawing=off \
    click_script="media-control next-track"
