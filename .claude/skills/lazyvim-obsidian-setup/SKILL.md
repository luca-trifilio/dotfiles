---
name: lazyvim-obsidian-setup
description: Use when configuring Neovim/LazyVim for Obsidian vault editing, fixing wikilink diagnostics, or resolving LSP/spellcheck conflicts with obsidian.nvim.
---

## Problem: marksman LSP flags wikilinks as errors

LazyVim installs **marksman** (markdown LSP) via Mason by default.
Marksman checks that `[[wikilinks]]` resolve to existing files — it doesn't
understand Obsidian vaults, so it flags every link to a non-existent note with:

> Link to non-existent document 'NoteName'

**Fix** — add to `nvim/lua/config/autocmds.lua`:

```lua
-- Disable marksman LSP: obsidian.nvim handles wikilink resolution
vim.lsp.enable("marksman", false)
```

Then uninstall from Mason (optional, won't restart on sync):
`:MasonUninstall marksman`

## Problem: spellcheck flags words inside wikilinks

LazyVim enables spellcheck in markdown via the `lazyvim_wrap_spell` augroup.
Words inside `[[Wikilink Names]]` get underlined as spelling errors.

**Fix** — add to `nvim/lua/config/autocmds.lua`:

```lua
-- Avoid using spellcheck in markdown
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
```

## Problem: word wrap lost after removing lazyvim_wrap_spell

Deleting the `lazyvim_wrap_spell` augroup also removes `wrap = true` for markdown.
Long lines run off-screen.

**Fix** — after the `del_augroup` call, add a new autocmd:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
```

`linebreak` wraps at word boundaries instead of mid-word.

## Problem: autocomplete shows up in markdown

blink.cmp (LazyVim default) triggers completion in markdown files.

**Fix** — add to any plugin file (e.g. `markdown.lua`):

```lua
{
  "saghen/blink.cmp",
  opts = {
    enabled = function()
      return vim.bo.filetype ~= "markdown"
    end,
  },
},
```

## Problem: obsidian.nvim and render-markdown.nvim both render bullets

Both plugins use conceal to replace `-`/`*`/`+` with styled bullets.
Result: double rendering, degraded appearance.

**Fix** — disable obsidian.nvim's bullet rendering and let render-markdown handle it:

```lua
-- in obsidian.nvim opts:
ui = {
  bullets = false,
  -- other hl_groups config...
},
```

## Daily notes: hierarchical folder structure

obsidian.nvim's `daily_notes.folder` does **not** support functions — it's a static string.
To get year/month subfolders (`Diario/2026/04/2026-04-14.md`), encode the hierarchy in `date_format`:

```lua
daily_notes = {
  folder = "20 - Diario",
  date_format = "%Y/%m/%Y-%m-%d",
},
```

The path becomes `folder/date_format.md` → `20 - Diario/2026/04/2026-04-14.md`.

## Notes

- Both fixes go in `autocmds.lua` — loaded on `VeryLazy` event before LSPs attach
- `vim.lsp.enable("marksman", false)` prevents startup but Mason keeps the binary;
  `:MasonUninstall marksman` is optional cleanup
- obsidian.nvim handles all navigation/completion for wikilinks
