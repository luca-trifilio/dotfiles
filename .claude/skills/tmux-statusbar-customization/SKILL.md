---
name: tmux-statusbar-customization
description: This skill should be used when the user asks to customize the tmux statusbar, adopt a "pill" style layout, use powerline/rounded separators, write custom statusbar scripts, or replicate the omerxx/Catppuccin statusbar style with a different color palette.
---

# tmux Statusbar Customization

## Goal

Replicate the omerxx/Catppuccin "pill" statusbar style (rounded powerline caps, 2-segment window tabs, modular status pills) while keeping a custom color palette (e.g. Dracula).

## Approach: standalone `statusbar.sh` script

Using a standalone script gives full control and avoids plugin API incompatibilities. The script generates tmux format strings and applies them via `tmux set-option`.

### Script structure

```bash
#!/usr/bin/env bash
# Unicode chars — must be written via Python (see below)
cap_l=""   # U+E0B6
cap_r=""   # U+E0B4
block="█"  # U+2588

# Dracula palette
fg="#f8f8f2"
bg="#282a36"
dark_gray="#44475a"
gray="#6272a4"
purple="#bd93f9"
orange="#ffb86c"
green="#50fa7b"
cyan="#8be9fd"
pink="#ff79c6"

pill() {
  local icon="$1" color="$2" text="$3"
  printf '#[fg=%s,bg=default]%s#[fg=%s,bg=%s] %s #[fg=%s,bg=%s] %s #[fg=%s,bg=default]%s' \
    "$color" "$cap_l" "$dark_gray" "$color" "$icon" \
    "$fg" "$gray" "$text" "$gray" "$cap_r"
}

status_left="  $(pill "" "$green" "#S")  "

cpu=$(~/.config/tmux/scripts/cpu.sh)
ram=$(~/.config/tmux/scripts/ram.sh)
datetime=$(date "+%a %d %b  %H:%M")
status_right="$(pill "" "$pink" "$cpu") $(pill "" "$cyan" "$ram") $(pill "" "$purple" "$datetime")"

win_inactive="#[fg=$gray,bg=default]${cap_l}#[fg=$fg,bg=$gray] #W #[fg=$dark_purple,bg=$gray]${block}#[fg=$fg,bg=$dark_purple] #I #[fg=$dark_purple,bg=default]${cap_r}"
win_active="#[fg=$gray,bg=default]${cap_l}#[fg=$fg,bg=$gray,bold] #W #[fg=$orange,bg=$gray]${block}#[fg=$fg,bg=$orange,bold] #I #[fg=$orange,bg=default]${cap_r}"

tmux set-option -g status-left-length 100
tmux set-option -g status-right-length 500   # must exceed byte-length of format string
tmux set-option -g status-left "$status_left"
tmux set-option -g status-right "$status_right"
tmux set-option -g window-status-format "$win_inactive"
tmux set-option -g window-status-current-format "$win_active"
tmux set-option -g window-status-separator "  "
```

### Invoke from tmux.conf

```tmux
# Run after TPM init (must come after `run tpm`)
set-hook -g after-new-session 'run "~/.config/tmux/statusbar.sh"'
run "~/.config/tmux/statusbar.sh"
```

## Critical: writing Unicode characters

The Write tool and most editors silently drop Nerd Font glyphs (U+E0B4, U+E0B6, U+2588). Always write files containing these chars via Python:

```bash
python3 - <<'EOF'
content = open('/path/to/statusbar.sh').read()  # or build string directly
content = content.replace('CAP_L', '\ue0b6').replace('CAP_R', '\ue0b4')
open('/path/to/statusbar.sh', 'w').write(content)
EOF
```

Or write the entire file via Python with escape sequences in the string literals.

## status-right-length

The format string for `status-right` with 3 pills is ~444 bytes. Default `status-right-length` (200) truncates it silently. Always set:

```tmux
tmux set-option -g status-right-length 500
```

## cpu/ram scripts (macOS)

```bash
# scripts/cpu.sh
cpuvalue=$(ps -A -o %cpu | awk -F. '{s+=$1} END {print s}')
cpucores=$(sysctl -n hw.logicalcpu)
echo "$((cpuvalue / cpucores))%"

# scripts/ram.sh
used=$(vm_stat | grep ' active\|wired\|compressor\|speculative' | sed 's/[^0-9]//g' \
  | paste -sd ' ' - | awk -v p=$(pagesize) '{printf "%d", ($1+$2+$3+$5)*p/1073741824}')
total=$(sysctl -n hw.memsize | awk '{printf "%d", $1/1073741824}')
echo "${used}GB/${total}GB"
```

## Icon discovery via fontTools

To find correct Nerd Font codepoints for the installed font:

```python
from fontTools.ttLib import TTFont
font = TTFont("/path/to/JetBrainsMonoNerdFontMono-Regular.ttf")
cmap = font.getBestCmap()
# Search by Unicode codepoint
print(hex(0xf538), 0xf538 in cmap)   # fa-memory
print(hex(0xefc5), 0xefc5 in cmap)   # nf-ram
```

JetBrainsMono Nerd Font Mono constrains all glyphs to 1-cell width — suitable for statusbar.

## bg=default color matching

`bg=default` in tmux format strings does **not** reliably inherit the terminal emulator's background. It may render as a slightly different shade than Ghostty's background color. Known workaround: use the exact hex of the terminal bg (get it via `ghostty +show-config | grep background`). Even then, a visible seam may appear at statusbar edges. This is a known limitation.

## Stale settings after config change

`prefix + r` (source-file) does not clear previously set tmux options — old values persist for the session lifetime. To fully reset:

```bash
tmux kill-server
# then reopen Ghostty / restart tmux
```

## Ghostty window padding

Adding `window-padding-x = 16` / `window-padding-y = 16` in Ghostty config adds visual breathing room around terminal content (similar to omerxx's layout). Do **not** set `window-padding-color` — both `background` and `extend` values create a visible color band that differs from the terminal background.
