return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ---@module 'obsidian'
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    ui = {
      bullets = vim.NIL, ---@diagnostic disable-line: assign-type-mismatch
      hl_groups = {
        ObsidianRefText = { fg = "#8BE9FD", underline = true },
      },
    },
    workspaces = {
      {
        name = "work",
        path = "~/Documents/Taccuino Cerusico",
      },
    },
    daily_notes = {
      folder = "20 - Diario",
      date_format = "%Y/%m/%Y-%m-%d",
    },
    frontmatter = { enabled = false },
  },
}
