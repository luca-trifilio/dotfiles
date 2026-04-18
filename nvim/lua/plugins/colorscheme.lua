return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "macchiato",
      custom_highlights = function(colors)
        return {
          -- Heading text (treesitter + rainbow)
          rainbowcol1 = { fg = colors.red },
          rainbowcol2 = { fg = colors.peach },
          rainbowcol3 = { fg = colors.yellow },
          rainbowcol4 = { fg = colors.green },
          rainbowcol5 = { fg = colors.blue },
          rainbowcol6 = { fg = colors.mauve },
          -- render-markdown.nvim headings (matches Obsidian Baseline)
          RenderMarkdownH1 = { fg = colors.red,   bold = true },
          RenderMarkdownH2 = { fg = colors.peach,  bold = true },
          RenderMarkdownH3 = { fg = colors.yellow, bold = true },
          RenderMarkdownH4 = { fg = colors.green,  bold = true },
          RenderMarkdownH5 = { fg = colors.blue,   bold = true },
          RenderMarkdownH6 = { fg = colors.mauve,  bold = true },
          -- Bold text and inline code (matches Obsidian Baseline)
          ["@markup.strong"]                = { fg = colors.peach, bold = true },
          ["@markup.raw.markdown_inline"]   = { fg = colors.peach },
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
}
