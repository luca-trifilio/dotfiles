---
id: sketchybar-rewrite-shell-catppuccin
description: Rewrite sketchybar config from SbarLua to shell scripts based on tanerijun's config, applying Catppuccin Macchiato theme and JetBrains Mono NF font; install media-control; remove old Lua files
status: implemented
created: 2026-05-10T00:00:00Z
---
# Task: Rewrite sketchybar config (SbarLua → shell scripts)

## Context (from conversation)

- Current config: SbarLua (Lua-based), FelixKratz default structure
- Target: tanerijun's shell-script config, adapted
- Theme: Catppuccin Macchiato (replacing Nord)
- Font: JetBrains Mono Nerd Font (replacing Maple Mono NF CN)
- Media: media-control CLI (install first; try replacing nowplaying-cli)
- Remove: apple logo item (user removed previously)
- Remove: old Lua files after rewrite
- AeroSpace: keep existing workspace assignments; pass PREV_WORKSPACE (already done)

## Research findings

### Catppuccin Macchiato palette (ARGB)
- Base:     0xFF24273A  (bar bg at ~65%: 0xA624273A)
- Mantle:   0xFF1E2030
- Surface0: 0xFF363A4F  (borders)
- Surface1: 0xFF494D64
- Text:     0xFFCAD3F5
- Subtext1: 0xFFB8C0E0
- Mauve:    0xFFC6A0F6  (media playing, purple accent)
- Red:      0xFFED8796
- Peach:    0xFFF5A97F  (orange)
- Yellow:   0xFFEED49F
- Green:    0xFFA6DA95
- Teal:     0xFF8BD5CA
- Blue:     0xFF8AADF4  (primary accent, replaces NORD8)
- Sapphire: 0xFF7DC4E4
- Lavender: 0xFFB7BDF8

### Files to create
- sketchybarrc
- helpers/constants.sh
- helpers/icon_map_fn.sh
- items/spaces.sh
- items/clock.sh
- items/battery.sh
- items/volume.sh
- items/ip_address.sh
- items/media.sh
- plugins/battery.sh
- plugins/clock.sh
- plugins/ip_address.sh
- plugins/media.sh
- plugins/media_click.sh
- plugins/space.sh
- plugins/space_windows.sh
- plugins/volume.sh
- plugins/volume_click.sh

### Files to remove
- bar.lua, colors.lua, default.lua, icons.lua, init.lua, settings.lua
- items/*.lua (apple, calendar, front_app, media, menus, spaces)
- items/widgets/*.lua (battery, cpu, init, volume, wifi)
- helpers/app_icons.lua, helpers/default_font.lua, helpers/init.lua

### tanerijun plugin content: confirmed
All plugin scripts fetched. media.sh uses `media-control get | jq`.
