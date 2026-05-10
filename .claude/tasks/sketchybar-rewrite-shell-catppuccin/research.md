# Research: sketchybar-rewrite-shell-catppuccin

## Current state

- Config at: `~/Progetti/dotfiles/sketchybar/` (stowed to `~/.config/sketchybar/`)
- Entry point: `sketchybarrc` → `#!/usr/bin/env lua` → `require("helpers"); require("init")`
- All items/plugins written in Lua (SbarLua)
- AeroSpace integration already in place: `exec-on-workspace-change` passes `FOCUSED_WORKSPACE` + `PREV_WORKSPACE`

## Files to remove (Lua layer)

- `bar.lua`, `colors.lua`, `default.lua`, `icons.lua`, `init.lua`, `settings.lua`
- `items/apple.lua`, `items/calendar.lua`, `items/front_app.lua`, `items/media.lua`, `items/menus.lua`, `items/spaces.lua`
- `items/init.lua`, `items/widgets/init.lua`, `items/widgets/battery.lua`, `items/widgets/cpu.lua`, `items/widgets/volume.lua`, `items/widgets/wifi.lua`
- `helpers/app_icons.lua`, `helpers/default_font.lua`, `helpers/init.lua`

## Files to keep

- `helpers/event_providers/` (compiled C binaries, not used by new config but harmless)
- `helpers/menus/` (same)

## Dependencies

- `font-sketchybar-app-font`: ✅ already installed
- `media-control`: ❌ not installed → `brew install nicowillis/media-control/media-control` (or similar tap)
- `jq`: check needed
- `SwitchAudioSource`: check needed

## Target structure (based on tanerijun's config, adapted)

```
sketchybar/
  sketchybarrc              # main entry (bash)
  helpers/
    constants.sh            # Catppuccin Macchiato palette + theme vars
    icon_map_fn.sh          # app name → sketchybar-app-font glyph
  items/
    spaces.sh               # AeroSpace workspaces
    clock.sh                # date/time
    battery.sh              # battery
    volume.sh               # volume slider
    ip_address.sh           # network status
    media.sh                # media-control widget
  plugins/
    space.sh                # mouse click handler for spaces
    space_windows.sh        # workspace_change / front_app_switched handler
    battery.sh
    clock.sh
    ip_address.sh
    media.sh
    media_click.sh
    volume.sh
    volume_click.sh
```

## Catppuccin Macchiato palette (ARGB 0xAARRGGBB)

```
Base:     0xFF24273A  → bar bg at 65%: 0xA624273A
Mantle:   0xFF1E2030
Surface0: 0xFF363A4F  → borders, popup bg
Surface1: 0xFF494D64
Overlay1: 0xFF8087A2
Text:     0xFFCAD3F5
Subtext1: 0xFFB8C0E0
Mauve:    0xFFC6A0F6  → media playing accent
Red:      0xFFED8796
Peach:    0xFFF5A97F  → orange/peach
Yellow:   0xFFEED49F
Green:    0xFFA6DA95
Teal:     0xFF8BD5CA
Blue:     0xFF8AADF4  → primary accent (replaces Nord NORD8)
Sapphire: 0xFF7DC4E4
Lavender: 0xFFB7BDF8
```

## Key adaptations from tanerijun

| tanerijun | user adaptation |
|---|---|
| Nord colors | Catppuccin Macchiato |
| Maple Mono NF CN | JetBrains Mono Nerd Font |
| Apple logo item | omit |
| Spotify item | omit (commented out in tanerijun anyway) |
| Workspaces 1-9 | dynamic via `aerospace list-workspaces` (user has 1-9 + letters) |
| `after-startup-command = []` | keep user's (launches sketchybar + borders) |
| front_app (disabled) | omit |
| clock format: `%a %Y/%m/%d %H:%M` | keep (or adapt) |

## Plugin implementations (confirmed from source)

### media.sh
Uses `media-control get | jq` to extract `.title`, `.artist`, `.bundleIdentifier`, `.playbackRate`.
Maps bundle IDs: `com.spotify.client`→󰓇, `com.apple.Music`→󰎆, browser→󰖟.
Shows/hides item based on playbackRate.

### space_windows.sh
On `aerospace_workspace_change`: unhighlights all, highlights focused, reloads icon strips for prev+current, updates display assignments for multi-monitor.
On `front_app_switched` / `window_detected`: reloads icons for current workspace.

### volume.sh / volume_click.sh
Left click: animate slider width 0↔100 (tanh 30 frames).
Right/shift click: SwitchAudioSource device popup.

### ip_address.sh
Uses `scutil --nwi` to detect VPN (utun/ppp), wifi, or offline.
