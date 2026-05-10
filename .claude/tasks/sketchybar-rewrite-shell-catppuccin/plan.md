# Plan: sketchybar-rewrite-shell-catppuccin

## Goal
Replace SbarLua sketchybar config with shell-based config inspired by tanerijun, themed Catppuccin Macchiato + JetBrains Mono NF, with media-control widget. Old Lua files removed; sketchybar restarts cleanly.

## Approach
1. Install missing CLI deps (media-control, jq, SwitchAudioSource if missing).
2. Build new shell config alongside Lua files (different filenames, no clobber yet).
3. Swap `sketchybarrc` shebang from lua to bash last.
4. Remove Lua files only after new config validated.
5. `brew services restart sketchybar` and verify.

## Steps

### 1. Install runtime dependencies
- **Action**: `brew install media-control jq switchaudio-osx` (skip if already present, check with `command -v`).
- **Verify**: `media-control get | jq .` returns JSON; `SwitchAudioSource -a` lists devices.

### 2. Create helpers/constants.sh
- **Files**: `sketchybar/helpers/constants.sh`
- **Action**: Export Catppuccin Macchiato palette vars (BASE, MANTLE, SURFACE0/1, TEXT, BLUE, MAUVE, PEACH, GREEN, RED, YELLOW, TEAL, LAVENDER) as 0xAARRGGBB. Export `FONT="JetBrainsMono Nerd Font"`, `FONT_FACE`, `ICON_FONT="sketchybar-app-font:Regular:14.0"`, padding/height vars, `BAR_COLOR=0xA624273A`.
- **Verify**: `source` it in a shell, echo vars.

### 3. Create helpers/icon_map_fn.sh
- **Action**: Port tanerijun's `icon_map_fn.sh` (sketchybar-app-font lookup function `__icon_map`).
- **Verify**: `source ./icon_map_fn.sh; __icon_map "Safari"; echo "$icon_result"` returns a glyph.

### 4. Write top-level sketchybarrc (bash)
- **Files**: `sketchybar/sketchybarrc.new` (temp name)
- **Action**: `#!/usr/bin/env bash` shebang. Source constants. Set `bar` defaults (color, height, padding, position=top, sticky, y_offset, margin, corner_radius, blur). Set `default` (font, padding, label/icon color from TEXT). Source items in order: spaces, clock, battery, volume, ip_address, media. End with `sketchybar --update`.
- **Verify**: `bash -n sketchybarrc.new` (syntax only).

### 5. items/spaces.sh + plugins/space.sh + plugins/space_windows.sh
- **Action**: Iterate `aerospace list-workspaces --all`, create one `space.N` item per workspace with click_script and `aerospace_workspace_change` subscription. space_windows.sh handles workspace change (highlight focused via BLUE, dim others via SURFACE1, refresh icon strip via `aerospace list-windows --workspace N` + `__icon_map`). space.sh on click runs `aerospace workspace N`.
- **Verify**: Switch workspaces in AeroSpace, focused pill highlights and shows app icons.

### 6. items/clock.sh + plugins/clock.sh
- **Action**: Right-aligned item, 10s update freq, format `%a %Y/%m/%d %H:%M`, calendar icon, BLUE accent.
- **Verify**: Time visible and updates.

### 7. items/battery.sh + plugins/battery.sh
- **Action**: Right-aligned, subscribes to `system_woke` and `power_source_change`, parses `pmset -g batt`, icon glyph by percentage, color GREEN/YELLOW/RED thresholds.
- **Verify**: Unplug/plug shows correct icon.

### 8. items/volume.sh + plugins/volume.sh + plugins/volume_click.sh
- **Action**: Subscribe to `volume_change`. Slider widget with PEACH highlight. Left-click toggles slider visibility (animated). Right/shift click invokes `SwitchAudioSource` chooser.
- **Verify**: Volume keys update bar; slider animates on click.

### 9. items/ip_address.sh + plugins/ip_address.sh
- **Action**: Subscribe to `network_change` + `system_woke`. Parse `scutil --nwi` to detect utun (VPN→TEAL), en0 (WiFi→BLUE), or none (RED).
- **Verify**: Toggle WiFi off/on, label updates.

### 10. items/media.sh + plugins/media.sh + plugins/media_click.sh
- **Action**: Run `media-control stream` as subscription source via `nohup` started from sketchybarrc OR poll-mode (use `media-control get` on `media_change` custom event). Choose poll on `routine` 5s + click. Map bundle IDs to glyphs (Spotify, Apple Music, browser fallback). Hide when `playbackRate==0`. Click toggles play/pause via `media-control toggle-play-pause`.
- **Verify**: Play music in Spotify/Music, title appears with MAUVE accent.

### 11. Switch entry point
- **Action**: `mv sketchybarrc sketchybarrc.luabak` then `mv sketchybarrc.new sketchybarrc`; `chmod +x sketchybarrc` and all `*.sh` under helpers/items/plugins.
- **Verify**: `head -1 sketchybarrc` shows bash shebang.

### 12. Remove Lua files
- **Files**: `bar.lua colors.lua default.lua icons.lua init.lua settings.lua items/*.lua items/widgets/*.lua helpers/*.lua sketchybarrc.luabak`
- **Action**: `git rm` each. Keep `helpers/event_providers/` and `helpers/menus/` directories.
- **Verify**: `find sketchybar -name '*.lua'` returns nothing.

### 13. Restart and validate
- **Action**: `brew services restart sketchybar`; tail `~/Library/LaunchAgents` log or `sketchybar --query bar`.
- **Verify**: Bar appears, all items render, AeroSpace workspace switching highlights correctly, no errors in Console.app for sketchybar.

## Risks
- **media-control tap unknown** → check `brew search media-control`; fallback to `nicowillis/tap` or build from npm/source as documented in tanerijun repo.
- **JetBrains Mono NF not installed** → run `brew list --cask font-jetbrains-mono-nerd-font` first; install if missing.
- **AeroSpace workspace IDs include letters** → loop over `aerospace list-workspaces --all` output (don't hard-code 1-9).
- **Removing Lua before new config works** → keep `.luabak` until after restart succeeds; remove in step 12.
- **SbarLua still referenced** → confirm sketchybarrc no longer sources lua; uninstall SbarLua not required (harmless if unused).
- **Sketchybar permission issues on script exec** → ensure `chmod +x` on every shell file.

## Out of Scope
- Popup menus (tanerijun's menus/ widgets).
- CPU widget, WiFi-detail widget, calendar popup.
- Front-app display.
- Refactoring AeroSpace config beyond `exec-on-workspace-change` (already wired).
- Updating Obsidian docs (separate task).
