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

## Plugin extmark highlights vs treesitter highlights

Some plugins (e.g. obsidian.nvim) apply highlights via **extmarks**, not treesitter. These are independent layers that can overlap on the same text. When customizing colors for such text, **both layers must agree**:

1. **Treesitter layer** — groups like `@markup.link` in `groups.lua` (the fork)
2. **Plugin extmark layer** — groups like `ObsidianRefText`, configured in the plugin's `setup()` opts (e.g. `nvim/lua/plugins/obsidian.lua`)

### Example: obsidian.nvim wiki link colors

obsidian.nvim uses `ObsidianRefText` (applied via extmark) for all wiki links `[[...]]`. Treesitter independently applies `@markup.link` to the same text. To get consistent styling:

- In `groups.lua` (fork): `['@markup.link'] = { fg = colors.cyan, underline = true }`
- In `plugins/obsidian.lua` (nvim config): `ui = { hl_groups = { ObsidianRefText = { fg = "#8BE9FD", underline = true } } }`

If only one is changed, the other layer's colors bleed through.

### How to diagnose

Use `:Inspect` on the highlighted text to see which highlight groups are active and their source (treesitter, extmark, syntax). This reveals which layers need to be changed.

### obsidian.nvim highlight groups reference

- `ObsidianRefText` — wiki links and markdown links (the main one)
- `ObsidianExtLinkIcon` — icon for external URLs
- `ObsidianTodo`, `ObsidianDone`, `ObsidianRightArrow`, `ObsidianTilde`, `ObsidianImportant` — checkboxes
- `ObsidianBullet` — bullet markers
- `ObsidianTag` — tags
- `ObsidianBlockID` — block IDs
- `ObsidianHighlightText` — `==highlighted==` text

**Note:** obsidian.nvim does NOT distinguish existing vs non-existing links (as of v3.x). All wiki links get `ObsidianRefText`. This is planned for v4.0 via LSP semantic highlighting (see issues #249, #309, #792).

## Notes

- Groups added to `groups.lua` are applied at `ColorScheme` load automatically
- render-markdown.nvim sets its groups with `default = true`, so the theme wins if it defines them first (which it does, since it loads at ColorScheme)
- After the fork, the only source of truth for colors is `palette.lua` in the fork
