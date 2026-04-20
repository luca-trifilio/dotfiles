return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "macchiato",
      transparent_background = true,
      custom_highlights = function(colors)
        return {
          -- Heading text (treesitter) — questi sovrascrivono i default catppuccin
          rainbow1 = { fg = colors.red },
          rainbow2 = { fg = colors.peach },
          rainbow3 = { fg = colors.yellow },
          rainbow4 = { fg = colors.green },
          rainbow5 = { fg = colors.blue },
          rainbow6 = { fg = colors.mauve },
          -- render-markdown.nvim headings (allineati ai rainbow)
          RenderMarkdownH1 = { fg = colors.red, bold = true },
          RenderMarkdownH2 = { fg = colors.peach, bold = true },
          RenderMarkdownH3 = { fg = colors.yellow, bold = true },
          RenderMarkdownH4 = { fg = colors.green, bold = true },
          RenderMarkdownH5 = { fg = colors.blue, bold = true },
          RenderMarkdownH6 = { fg = colors.mauve, bold = true },
          -- render-markdown bullets
          RenderMarkdownBullet = { fg = colors.lavender },
          -- Links (treesitter groups for markdown)
          ["@markup.link.label.markdown_inline"] = { fg = colors.sky },
          ["@markup.link.markdown_inline"] = { fg = colors.sky },
          -- Bold text and inline code (matches Obsidian Baseline)
          ["@markup.strong"] = { fg = colors.peach, bold = true },
          ["@markup.raw.markdown_inline"] = { fg = colors.peach },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        lualine_z = {},
      },
    },
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
    },
  },
}
