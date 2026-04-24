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
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      enabled = true,
      preset = "obsidian",
      heading = {
        border = true,
        position = "inline",
      },
      code = {
        sign = false,
      },
      bullet = {
        left_pad = 2,
      },
    },
  },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    cmd = { "Obsidian" },
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/Documents/Taccuino Cerusico/*.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Documents/Taccuino Cerusico/*.md",
    },
    ---@module 'obsidian'
    opts = {
      legacy_commands = false, -- this will be removed in the next major release
      ui = {
        enable = false,
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
