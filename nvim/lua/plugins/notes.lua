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
    "preservim/vim-pencil",
    ft = "markdown",
    config = function()
      vim.g["pencil#wrapModeDefault"] = "soft"
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.fn["pencil#init"]()
        end,
      })
    end,
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
        backgrounds = {},
        above = " ",
        below = " ",
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
    init = function()
      require("which-key").add({ { "<leader>o", group = "obsidian", icon = "󰇈" } })
      vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
        pattern = vim.fn.expand("~") .. "/Documents/Taccuino Cerusico/*.md",
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = "it,en"
        end,
      })
    end,
    keys = {
      { "<leader>od", "<cmd>Obsidian today<cr>", desc = "today" },
      { "<leader>og", "<cmd>Obsidian dailies<cr>", desc = "dailies" },
      { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "quick switch" },
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "new note" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "search" },
      { "<leader>ot", "<cmd>Obsidian tags<cr>", desc = "tags" },
    },
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
      templates = {
        folder = "30 - Modelli",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
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
