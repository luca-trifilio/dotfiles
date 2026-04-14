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

## Notes

- Both fixes go in `autocmds.lua` — loaded on `VeryLazy` event before LSPs attach
- `vim.lsp.enable("marksman", false)` prevents startup but Mason keeps the binary;
  `:MasonUninstall marksman` is optional cleanup
- obsidian.nvim handles all navigation/completion for wikilinks
