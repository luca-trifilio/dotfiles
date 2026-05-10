#!/bin/bash
source "$CONFIG_DIR/helpers/constants.sh"

ARTWORK_FILE="/tmp/sketchybar_artwork"
ARTWORK_TRACK_FILE="/tmp/sketchybar_artwork_track"

update_media() {
  command -v media-control >/dev/null 2>&1 || { hide_media; return; }
  MEDIA_JSON=$(media-control get 2>/dev/null) || { hide_media; return; }

  TITLE=$(echo "$MEDIA_JSON" | jq -r '.title // empty')
  PLAYBACK_RATE=$(echo "$MEDIA_JSON" | jq -r '.playbackRate // 0')

  if [ -z "$TITLE" ] || [ "$TITLE" = "null" ] || \
     [ "$PLAYBACK_RATE" = "0" ] || [ "$PLAYBACK_RATE" = "0.0" ]; then
    hide_media; return
  fi

  ARTIST=$(echo "$MEDIA_JSON" | jq -r '.artist // empty')
  [ "$ARTIST" = "null" ] && ARTIST=""

  # Artwork — re-extract only on track change
  CURRENT_TRACK="$TITLE::$ARTIST"
  LAST_TRACK=$(cat "$ARTWORK_TRACK_FILE" 2>/dev/null)
  if [ "$CURRENT_TRACK" != "$LAST_TRACK" ] && command -v nowplaying-cli >/dev/null 2>&1; then
    nowplaying-cli get artworkData 2>/dev/null | base64 -d > "$ARTWORK_FILE" 2>/dev/null
    echo "$CURRENT_TRACK" > "$ARTWORK_TRACK_FILE"
  fi

  sketchybar --set media_bracket background.drawing=on

  sketchybar --set media_title label="$TITLE" drawing=on label.width=dynamic \
    --set media_artist drawing=on label.width=dynamic

  if [ -n "$ARTIST" ]; then
    sketchybar --set media_artist label="$ARTIST" drawing=on
  else
    sketchybar --set media_artist drawing=off
  fi

  if [ -s "$ARTWORK_FILE" ]; then
    IMG_H=$(sips -g pixelHeight "$ARTWORK_FILE" 2>/dev/null | awk '/pixelHeight/{print $2}')
    SCALE=$(LC_ALL=C awk "BEGIN{printf \"%.4f\", ${ITEM_HEIGHT:-24} / ${IMG_H:-600}}")
    sketchybar --set media_art \
      background.image="$ARTWORK_FILE" \
      background.image.drawing=on \
      background.image.scale="$SCALE" \
      drawing=on
  else
    sketchybar --set media_art drawing=off
  fi
}

hide_media() {
  sketchybar --set media_art drawing=off \
    --set media_title drawing=off popup.drawing=off \
    --set media_artist drawing=off \
    --set media_bracket background.drawing=off
}

case "$SENDER" in
  "mouse.entered")
    sketchybar --set media_title popup.drawing=on ;;
  "mouse.exited"|"mouse.exited.global")
    sketchybar --set media_title popup.drawing=off ;;
  *)
    update_media ;;
esac
