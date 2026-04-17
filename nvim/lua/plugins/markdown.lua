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
        border = true,
        border_virtual = true,
        above = "▄",
        below = "▀",
      },
      code = {
        border = "thin",
        above = "▄",
        below = "▀",
      },
    },
  },
}
