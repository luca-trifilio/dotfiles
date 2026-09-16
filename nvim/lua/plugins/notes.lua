return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- obsidian.nvim handles wikilink resolution; enabling marksman here (rather than
        -- vim.lsp.enable in autocmds.lua) avoids a startup race where marksman can attach
        -- via mason-lspconfig's automatic enable before a later disable call runs.
        marksman = { enabled = false },
      },
    },
  },
  {
    -- Vim's formatoptions/comments (fb: flags) only handles hanging-indent for
    -- soft-wrapped continuation of an existing bullet, not creating a new one on <CR>.
    "bullets-vim/bullets.vim",
    ft = "markdown",
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          -- obsidian.nvim migrated to in-process LSP; "lsp" is required
          markdown = { "lsp" },
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
      -- Buffer-local nav keymaps, scoped to vault notes only (fires only for buffers
      -- obsidian.nvim recognizes as notes, so it never leaks to other markdown files).
      vim.api.nvim_create_autocmd("User", {
        pattern = "ObsidianNoteEnter",
        callback = function(ev)
          local api = require("obsidian.api")
          -- <CR> is already bound to smart_action via obsidian.nvim's default
          -- keymap (vim.g.obsidian_default_keymap); rebind here only for clarity/ownership.
          vim.keymap.set("n", "<CR>", require("obsidian.actions").smart_action, {
            expr = true,
            buffer = ev.buf,
            desc = "Obsidian Smart Action",
          })
          vim.keymap.set("n", "<leader>ch", "<cmd>Obsidian toggle_checkbox<cr>", {
            buffer = ev.buf,
            desc = "toggle checkbox",
          })
          -- gf follows wikilinks inside notes, falls back to plain gf elsewhere/on failure.
          vim.keymap.set("n", "gf", function()
            local ok, link = pcall(api.cursor_link)
            if ok and link then
              vim.cmd("Obsidian follow_link")
            else
              vim.cmd("normal! gf")
            end
          end, { buffer = ev.buf, desc = "Obsidian follow link (gf)" })
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
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "backlinks" },
      { "<leader>ol", "<cmd>Obsidian link<cr>", desc = "link selection", mode = "v" },
      { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "rename note" },
      { "<leader>om", "<cmd>Obsidian template<cr>", desc = "insert template" },
      { "<leader>oc", "<cmd>Obsidian toc<cr>", desc = "table of contents" },
      { "<leader>ox", "<cmd>Obsidian extract_note<cr>", desc = "extract note", mode = "v" },
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
      -- :Obsidian new keeps the title as typed as the filename (frontmatter is disabled,
      -- so the filename is the note's only identity; no generated ID).
      note_id_func = function(title)
        return title
      end,
      workspaces = {
        {
          name = "taccuino",
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
