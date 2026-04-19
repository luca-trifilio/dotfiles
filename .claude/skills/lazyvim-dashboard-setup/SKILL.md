---
name: lazyvim-dashboard-setup
description: Use when the user asks to customize the LazyVim dashboard, change the ASCII header, organize nvim plugin files, or remove statusline elements like the clock.
---

## Custom dashboard header (snacks.nvim)

Create `nvim/lua/assets/logo.lua` returning a multiline string:

```lua
return [[
  your ascii art here
]]
```

Reference it in `nvim/lua/plugins/snacks.lua`:

```lua
{
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = require("assets.logo"),
      },
    },
  },
}
```

**Pitfalls:**
- `header` must be a string — not a function, not a table of strings
- To fetch exact bytes from a GitHub file (preserving Nerd Font glyphs): `gh api "repos/.../contents/path" --jq '.content' | base64 -d > file`
- Nerd Font glyphs corrupt when copy-pasted through terminal — always pipe raw bytes directly to file
- `opts = function() return { ... } end` works if you need to call `require()` at config time

## Plugin file organization

Power-user pattern (folke): few files by semantic category, not one file per plugin.

| File | Contents |
|---|---|
| `ui.lua` | colorscheme, statusline, navigator |
| `coding.lua` | gitsigns, LSP extras, language plugins |
| `notes.lua` | markdown, obsidian, completion overrides |
| `snacks.lua` | dashboard, picker, explorer |

## Remove lualine clock

```lua
{ "nvim-lualine/lualine.nvim", opts = { sections = { lualine_z = {} } } }
```
