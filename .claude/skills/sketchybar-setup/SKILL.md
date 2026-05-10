---
name: sketchybar-setup
description: Use when user asks to "configure sketchybar", "add a widget to the bar",
  "customize sketchybar", "add app icons to workspaces", "integrate sketchybar with
  AeroSpace", "change bar theme", or needs to add/modify any sketchybar item or plugin.
---

## Config location
`dotfiles/sketchybar/` → stowed to `~/.config/sketchybar/`.
Entry point: `sketchybarrc` (bash shebang, NOT lua).
Restart: `brew services restart sketchybar`.

## Structure
```
sketchybar/
  sketchybarrc          # bar + defaults + source items
  helpers/
    constants.sh        # palette, font, geometry exports
    icon_map_fn.sh      # app name → sketchybar-app-font glyph
  items/                # declare items (add + subscribe + set)
  plugins/              # event handlers (run by sketchybar on event)
```

## Shell vs SbarLua
Shell scripts are the standard. SbarLua is optional; avoid unless already in use.
Config uses `#!/usr/bin/env bash`, sources `helpers/constants.sh`, then sources each `items/*.sh`.

## Catppuccin Macchiato palette (ARGB 0xAARRGGBB)
```bash
BASE=0xFF24273A     MANTLE=0xFF1E2030   SURFACE0=0xFF363A4F
SURFACE1=0xFF494D64 TEXT=0xFFCAD3F5     SUBTEXT0=0xFFA5ADCB
BLUE=0xFF8AADF4     MAUVE=0xFFC6A0F6    PEACH=0xFFF5A97F
GREEN=0xFFA6DA95    RED=0xFFED8796      YELLOW=0xFFEED49F
TEAL=0xFF8BD5CA     LAVENDER=0xFFB7BDF8
BAR_COLOR=0xA624273A  # Base at 65% opacity
```

## AeroSpace workspace integration

### Trigger in aerospace.toml
```toml
exec-on-workspace-change = ['/bin/bash', '-c',
  'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE']
```

### Variabili env nel plugin — CRITICO
Il trigger rinomina le variabili: nel plugin usare `$FOCUSED_WORKSPACE` e `$PREV_WORKSPACE`, NON `$AEROSPACE_FOCUSED_WORKSPACE`:
```bash
# space_windows.sh
if [ -z "$FOCUSED_WORKSPACE" ]; then exit 0; fi
CURRENT_FOCUSED="$FOCUSED_WORKSPACE"
if [ -n "$PREV_WORKSPACE" ]; then reload_workspace_icon "$PREV_WORKSPACE"; fi
```

### Registrazione eventi — CRITICO
Senza questa riga le subscription non si attivano mai:
```bash
# items/spaces.sh — PRIMA del loop di creazione workspace
sketchybar --add event aerospace_workspace_change
sketchybar --add event window_detected
```

### Loop workspaces dinamico
Non hard-codare gli ID — usare `--all` per catturare sia numeri che lettere (M, S, T, O…):
```bash
for sid in $(aerospace list-workspaces --all); do
  sketchybar --add item space.$sid left \
             --subscribe space.$sid aerospace_workspace_change front_app_switched window_detected \
             --set space.$sid script="$PLUGIN_DIR/space_windows.sh" ...
done
```

### Highlight iniziale corretto
Non settare il workspace attivo durante la creazione degli item — il timing di `aerospace list-workspaces --focused` è inaffidabile al boot. Settarlo DOPO `sketchybar --update` in `sketchybarrc`:
```bash
sketchybar --update

INITIAL_FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
if [ -n "$INITIAL_FOCUSED" ]; then
  sketchybar --set space.$INITIAL_FOCUSED \
    icon.highlight=true label.highlight=true \
    icon.color=$WORKSPACE_ICON_HIGHLIGHT_COLOR \
    label.color=$WORKSPACE_LABEL_HIGHLIGHT_COLOR \
    background.border_color=$WORKSPACE_ITEM_BORDER_HIGHLIGHT_COLOR
fi
```

## App icons in workspace pills
Install font: `brew install --cask font-sketchybar-app-font` (already installed).
Font string: `sketchybar-app-font:Regular:14.0`.

Get app names per workspace (colonna 2 dell'output di aerospace):
```bash
apps=$(aerospace list-windows --workspace "$sid" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
```

Build icon strip:
```bash
icon_strip=" "
while read -r app; do
  icon_map "$app"; icon_strip+=" $icon_result"
done <<< "$apps"
```

Padding ottimale (numero incollato alle icone, respiro a destra):
```bash
icon.padding_left=10  icon.padding_right=0
label.padding_right=20  label.y_offset=-1
```

### Nomi app localizzati in icon_map
macOS restituisce nomi localizzati da `aerospace list-windows`. Aggiungere varianti:
- `"Musica"` → `:music:` (Music.app in italiano)
- Aggiungere altri nomi italiani/localizzati se mancano

## click_script vs script per distinguere left/right click
`click_script` NON riceve `$BUTTON` né `$MODIFIER`. Per distinguere tasto sinistro/destro, usare `script` con subscription a `mouse.clicked`:
```bash
# items/volume.sh — NON usare click_script
sketchybar --add item volume_icon right \
           --set volume_icon script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume_icon volume_change mouse.clicked mouse.exited.global
```
Nel plugin:
```bash
case "$SENDER" in
  "mouse.clicked")
    if [ "$BUTTON" = "right" ] || [ "$MODIFIER" = "shift" ]; then
      # right click action
    else
      # left click action
    fi ;;
  "mouse.exited.global")
    sketchybar --set "$NAME" popup.drawing=off ;;
esac
```

## Volume widget — popup invece di slider inline
Il slider inline si espande verso sinistra (brutto su right-aligned items). Usare popup:
```bash
# item
sketchybar --add item volume_icon right \
           --set volume_icon popup.align=right popup.height=40 \
                             script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume_icon volume_change mouse.clicked mouse.exited.global \
           \
           --add slider volume popup.volume_icon 200 \
           --set volume slider.highlight_color=... ...

# plugin — left click
sketchybar --set volume_icon popup.drawing=toggle

# plugin — mouse.exited.global
sketchybar --set volume_icon popup.drawing=off
```

## IP address widget
Parsing robusto di `scutil --nwi` (il formato varia tra versioni macOS):
```bash
IP=$(scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1)
IS_VPN=$(scutil --nwi | grep -E 'utun|ppp' | awk '{ print $1 }')

if [[ $IS_VPN != "" ]]; then
  ICON="󰖂"; COLOR=$IP_ICON_COLOR_VPN
elif [[ $IP != "" ]]; then
  ICON="󰖩"; COLOR=$IP_ICON_COLOR_WIFI
else
  ICON="󰖪"; COLOR=$IP_ICON_COLOR_OFFLINE
fi
```

## Media widget
Uses `media-control` CLI (`brew search media-control` per trovare il tap corretto).
Also needs `jq`.
```bash
MEDIA_JSON=$(media-control get 2>/dev/null)
TITLE=$(echo "$MEDIA_JSON" | jq -r '.title // empty')
BUNDLE_ID=$(echo "$MEDIA_JSON" | jq -r '.bundleIdentifier // empty')
PLAYBACK_RATE=$(echo "$MEDIA_JSON" | jq -r '.playbackRate // 0')
```
Bundle IDs: `com.spotify.client` → 󰓇, `com.apple.Music` → 󰎆.
Set `drawing=off` quando title è vuoto o playbackRate==0.

### updates — CRITICO
`updates=always` NON è un valore valido in sketchybar v2 — risulta silenziosamente come `off`.
Usare `updates=on`. Il default globale è `updates=when_shown` che blocca il polling quando `drawing=off`:
```bash
--set media_title updates=on update_freq=5
```

### Startup trigger con delay
`--trigger media_change` alla fine di `sketchybarrc` ha race condition. Usare background con sleep:
```bash
sketchybar --update
(sleep 1 && sketchybar --trigger media_change) &
```

### Hover su widget multi-item
`mouse.entered/exited` è per-item: hovering su `media_art` non triggera lo script di `media_title`.
Ogni item del widget deve fare subscribe e avere il proprio `script=`:
```bash
--set media_art script="$PLUGIN_DIR/media.sh" \
--subscribe media_art mouse.entered mouse.exited mouse.exited.global
```

### Layout stacked (felixkratz style)
Artist sopra / title sotto con `y_offset`, label parte nascosta:
```bash
# artist
label.y_offset=6  label.width=0  label.font="$FONT:Regular:9.0"
# title
label.y_offset=-5 label.width=0  label.font="$FONT:SemiBold:11.0"
```
Popup orizzontale: `popup.horizontal=on  popup.height=$ITEM_HEIGHT`

## Bar position
Attaccata al bordo superiore (nessun floating): `margin=0  y_offset=0  corner_radius=0`

## Disattivare sketchybar
```bash
brew services stop sketchybar
# In aerospace.toml: commentare le righe sketchybar in after-startup-command e exec-on-workspace-change
aerospace reload-config
# Riattivare: brew services start sketchybar + decommentare aerospace.toml
```

## Coerenza icone — Material Design (nf-md-*)
Usare nf-md-* per coerenza visiva:
| Widget | Icone |
|---|---|
| Calendar | 󰃭 |
| Wifi | 󰖩 connected, 󰖪 offline |
| Battery | 󰂄 charging, 󰁹 100%, 󰂁 80%, 󰁾 50%, 󰁼 30%, 󰁺 10% |
| Volume | 󰕾 high, 󰖀 mid, 󰕿 low, 󰖁 mute |

## Italian clock
```bash
sketchybar --set "$NAME" label="$(LC_ALL=it_IT.UTF-8 date +'%a %d %b %H:%M')"
```

## Gotchas
- Tutti i plugin `.sh` devono essere `chmod +x`.
- `media_change` event broken su Sequoia 15.4 — usare `media-control` CLI con `update_freq=2`.
- Native `space` type è legato a Mission Control, non AeroSpace — usare sempre `item` type.
- Rimuovere il display-switching logic da `space_windows.sh` su setup single-monitor (combatte con AeroSpace).
- Aggiornamenti senza restart: `sketchybar --trigger <event>` per forzare refresh singolo item.
