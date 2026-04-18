return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
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
