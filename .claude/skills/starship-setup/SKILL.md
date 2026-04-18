---
name: starship-setup
description: Use when setting up Starship prompt in dotfiles, migrating from p10k/oh-my-zsh,
  or applying Catppuccin theme. Trigger phrases: "set up starship", "migrate from p10k",
  "starship config", "prompt setup".
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

## Catppuccin Macchiato preset

Source: `catppuccin/starship` repo — `starship.toml` (base config + all palettes) and `themes/macchiato.toml` (palette only).

Minimal layout mirroring p10k lean:
```toml
"$schema" = 'https://starship.rs/config-schema.json'
palette = "catppuccin_macchiato"
add_newline = true
format = "$directory$git_branch$git_status$character"

[character]
success_symbol = "[[󰄛](green) ❯](peach)"
error_symbol = "[[󰄛](red) ❯](peach)"
vimcmd_symbol = "[󰄛 ❮](subtext1)"

[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold lavender"

[git_branch]
style = "bold mauve"
symbol = " "
format = "[$symbol$branch]($style) "

[git_status]
style = "peach"
format = '([$all_status$ahead_behind]($style) )'
modified = "*"
untracked = "?"

[palettes.catppuccin_macchiato]
# ... paste from catppuccin/starship themes/macchiato.toml
```

**The `"$schema"` key is required** — without it, starship silently ignores the config file.

## tmux pitfall

Existing tmux sessions inherit the environment from when they were created. After adding `STARSHIP_CONFIG` to `.zshrc`, open a **new tmux window** (`prefix + c`) or kill and restart the session — otherwise `STARSHIP_CONFIG` is unset inside tmux and starship falls back to default config silently.

## Diagnosing config not loading

```zsh
echo $STARSHIP_CONFIG                        # must be set
starship print-config | grep "^format"       # first line should be your custom format
STARSHIP_CONFIG=~/.config/starship/starship.toml starship print-config  # force-load to verify
```
