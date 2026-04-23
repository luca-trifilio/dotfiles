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
    opts = function(_, opts)
      local C = require("catppuccin.palettes").get_palette("macchiato")
      local left_round = vim.fn.nr2char(0xE0B6)
      local right_round = vim.fn.nr2char(0xE0B4)
      local mode_colors = {
        n = C.blue, i = C.green, v = C.mauve, V = C.mauve,
        ["\22"] = C.mauve, c = C.peach, R = C.red, Rv = C.red,
        no = C.blue, s = C.peach, S = C.peach, ic = C.green,
        cv = C.peach, ce = C.peach, r = C.teal, rm = C.teal,
        ["r?"] = C.teal, ["!"] = C.red, t = C.green,
      }
      local function mode_color() return mode_colors[vim.fn.mode()] or C.blue end

      opts.options = vim.tbl_extend("force", opts.options or {}, {
        theme = "catppuccin-nvim",
        section_separators = { left = "", right = "" },
        component_separators = "",
      })
      opts.sections = opts.sections or {}
      opts.sections.lualine_a = { { "mode", separator = { left = left_round }, right_padding = 2 } }
      opts.sections.lualine_c = { { "filename", path = 0 }, "diagnostics" }

      opts.sections.lualine_z = {
        {
          "filetype",
          colored = false,
          separator = { right = right_round },
          left_padding = 2,
          color = function()
            return { fg = C.surface0, bg = mode_color() }
          end,
        },
      }
      return opts
    end,
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
