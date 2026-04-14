---
name: nvim-colorscheme-fork
description: Use when the user wants to fork a Neovim colorscheme plugin to centralize highlight group customizations, instead of scattering vim.api.nvim_set_hl calls across plugin config files.
---

# Neovim Colorscheme Fork

## Purpose

Centralize all highlight group customizations inside a forked colorscheme plugin, instead of spreading `vim.api.nvim_set_hl` calls across autocmds, plugin init functions, and config files.

## Workflow

### 1. Fork on GitHub

```bash
gh repo fork <upstream>/<plugin>.nvim --clone=false --fork-name=<plugin>.nvim
```

### 2. Clone into ~/Progetti

```bash
gh repo clone <your-username>/<plugin>.nvim ~/Progetti/<plugin>.nvim
```

### 3. Modify the fork

- **palette.lua**: add custom color variables (e.g. bg tints)
- **groups.lua**: add highlight groups at the end of the return table, using `colors.<name>` from palette

### 4. Commit and push

```bash
cd ~/Progetti/<plugin>.nvim
git add lua/ && git commit -m "Add custom highlight groups"
git push origin main
```

### 5. Update dotfiles

- `plugins/colorscheme.lua`: change plugin source to `<your-username>/<plugin>.nvim`
- Remove all `vim.api.nvim_set_hl` calls from `autocmds.lua` and plugin `init` functions
- Remove `config/palette.lua` if it only existed to feed those calls

### 6. Reload Neovim

Lazy picks up the new source on restart. If the old plugin is still cached, run `:Lazy update <plugin>.nvim` or fully restart.

## Mofiqul/dracula.nvim structure (reference)

- `lua/dracula/palette.lua` — color definitions + `@field` annotations
- `lua/dracula/groups.lua` — highlight groups table, receives `colors` from palette
- `lua/dracula/init.lua` — supports `overrides` callback as escape hatch

## Notes

- Groups added to `groups.lua` are applied at `ColorScheme` load automatically
- render-markdown.nvim sets its groups with `default = true`, so the theme wins if it defines them first (which it does, since it loads at ColorScheme)
- After the fork, the only source of truth for colors is `palette.lua` in the fork
