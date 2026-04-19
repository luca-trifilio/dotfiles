return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = require("assets.logo"),
        },
      },
      picker = {
        sources = {
          files = {
            hidden = true,
          },
          explorer = {
            hidden = true,
            ignored = true,
            exclude = { ".git" },
          },
        },
      },
    },
  },
  {
    "nvim-mini/mini.files",
    opts = {
      content = {
        filter = function(entry)
          return entry.name ~= ".git"
        end,
      },
    },
  },
}
