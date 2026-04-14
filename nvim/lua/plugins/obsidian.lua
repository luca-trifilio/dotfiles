return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    ui = {
      bullets = false,
      hl_groups = {
        ObsidianRefText = { fg = "#8BE9FD", underline = true },
      },
    },
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/personal",
      },
      {
        name = "work",
        path = "~/Documents/Taccuino Cerusico",
      },
    },
    daily_notes = {
      folder = "20 - Diario",
      date_format = "%Y/%m/%Y-%m-%d",
    },
  },
}
