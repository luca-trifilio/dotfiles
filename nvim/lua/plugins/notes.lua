return {
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          -- In markdown, only use obsidian sources (suppress generic completions)
          markdown = {},
        },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      render_modes = { "n", "i", "c" },
      heading = {
        enabled = true,
        border = true,
        border_virtual = true,
        border_prefix = false,
        above = " ",
        below = " ",
        backgrounds = {},
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
        custom = {},
      },
    },
  },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- use latest release, remove to use latest commit
    ---@module 'obsidian'
    opts = {
      legacy_commands = false, -- this will be removed in the next major release
      ui = {
        bullets = vim.NIL, ---@diagnostic disable-line: assign-type-mismatch
        hl_groups = {
          ObsidianRefText = { fg = "#8aadf4", underline = true },
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
      frontmatter = {
        enabled = false,
        func = function()
          return {}
        end,
      },
    },
  },
}
