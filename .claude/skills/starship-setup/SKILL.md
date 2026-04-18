---
name: starship-setup
description: Use when setting up Starship prompt in dotfiles, migrating from p10k/oh-my-zsh,
  or applying Catppuccin theme. Trigger phrases: "set up starship", "migrate from p10k",
  "starship config", "prompt setup", "nerd font symbols".
---

# Starship Prompt Setup

## File location (omerxx convention)

`dotfiles/starship/starship.toml` → stows to `~/.config/starship/starship.toml`

Set in `.zshrc`:
```zsh
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"
```

## Disabling p10k (oh-my-zsh)

- Remove p10k instant prompt block from top of `.zshrc`
- Set `ZSH_THEME=""`
- Remove `[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh` line

## Current layout (omerxx-inspired)

Left prompt: directory + character. Right prompt: git info.

```toml
"$schema" = 'https://starship.rs/config-schema.json'
palette = "catppuccin_macchiato"
add_newline = true

format = "$directory$character"
right_format = "$git_branch$git_status"

[character]
success_symbol = "[[󰄛](green) ❯](peach)"
error_symbol = "[[󰄛](red) ❯](peach)"
vimcmd_symbol = "[󰄛 ❮](subtext1)"

[directory]
truncation_length = 100
truncate_to_repo = false
style = "bold lavender"
read_only = " 󰌾"
read_only_style = "overlay2"

[git_branch]
style = "bold mauve"
format = "[$symbol$branch(:$remote_branch)]($style) "
# symbol embedded via nerd-font preset (see below)

[git_status]
style = "peach"
format = '([$all_status$ahead_behind]($style) )'
modified = "*"
untracked = "?"
staged = "+"
deleted = "✘"
renamed = "»"
ahead = "⇡"
behind = "⇣"
diverged = "⇕"

[palettes.catppuccin_macchiato]
# ... paste from catppuccin/starship themes/macchiato.toml
```

**The `"$schema"` key is required** — without it, starship silently ignores the config file.

## Nerd Font glyphs (PUA codepoints)

Write/Edit tools silently drop Private Use Area Unicode chars (U+E000–U+F8FF, U+F0000+). This affects all Nerd Font icons. **Never embed them via Write/Edit.**

Correct approach — use `starship preset nerd-font-symbols` as source of truth:

```bash
# Embed git_branch symbol (U+F418) from the official preset
SYMBOL_LINE=$(starship preset nerd-font-symbols | grep -A1 "\[git_branch\]" | tail -1)
awk -v sym="$SYMBOL_LINE" \
  '/^\[git_branch\]/{found=1} found && /^symbol/{print sym; found=0; next} 1' \
  ~/.config/starship/starship.toml > /tmp/s.toml && mv /tmp/s.toml ~/.config/starship/starship.toml
```

**Pitfall**: awk treats `$symbol`, `$branch` etc. as field variables — use `sed` to edit format strings containing `$`:

```bash
sed -i '' 's|old_format|new_format|' ~/.config/starship/starship.toml
```

## tmux pitfall

Existing tmux sessions inherit the environment from when they were created. After adding `STARSHIP_CONFIG` to `.zshrc`, open a **new tmux window** (`prefix + c`) or kill and restart the session — otherwise `STARSHIP_CONFIG` is unset inside tmux and starship falls back to default config silently.

## Diagnosing config not loading

```zsh
echo $STARSHIP_CONFIG                        # must be set
starship print-config | grep "^format"       # first line should be your custom format
STARSHIP_CONFIG=~/.config/starship/starship.toml starship print-config  # force-load to verify
```
