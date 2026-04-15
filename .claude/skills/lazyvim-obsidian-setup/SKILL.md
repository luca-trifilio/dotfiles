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

## Problem: autocomplete shows up in markdown but obsidian.nvim completion must stay

blink.cmp triggers generic completions (LSP, buffer, snippets) in markdown.
**Do NOT** use `enabled = function() return filetype ~= "markdown" end` — that kills
obsidian.nvim's completion sources too (`obsidian`, `obsidian_new`, `obsidian_tags`).

**Fix** — set `per_filetype.markdown = {}` and let obsidian.nvim auto-inject its sources:

```lua
{
  "saghen/blink.cmp",
  opts = {
    sources = {
      per_filetype = {
        markdown = {},
      },
    },
  },
},
```

obsidian.nvim detects a `markdown` key in `per_filetype` and injects `obsidian`, `obsidian_new`, `obsidian_tags` automatically (see `completion/plugin_initializers/blink.lua:inject_sources`). Using an explicit list means manually tracking new sources added by the plugin.

## Problem: obsidian.nvim and render-markdown.nvim both render bullets

Both plugins use conceal to replace `-`/`*`/`+` with styled bullets.
Result: double rendering, degraded appearance.

**Fix** — disable obsidian.nvim's bullet rendering and let render-markdown handle it:

```lua
-- in obsidian.nvim opts:
ui = {
  bullets = vim.NIL, -- NOT false: false passes the ~= nil guard and crashes ui.lua:223
  -- other hl_groups config...
},
```

`bullets` is typed `obsidian.config.UICharSpec|?`. Setting `false` causes `attempt to index field 'bullets' (a boolean value)` at `ui.lua:223`. `vim.NIL` tells lazy.nvim to set the key to `nil` during opts merge, which skips the rendering block.

## Problem: obsidian.nvim adds id/aliases/tags frontmatter to every note

Default `frontmatter.func` (`builtin.lua:151`) injects `{ id, aliases, tags }` on open/save.

**Fix**:

```lua
-- in obsidian.nvim opts:
frontmatter = { enabled = false },
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
