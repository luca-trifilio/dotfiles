return {
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      settings = {
        java = {
          inlayHints = {
            parameterNames = {
              enabled = "all",
            },
          },
          referencesCodeLens = {
            enabled = false,
          },
          implementationsCodeLens = {
            enabled = false,
          },
        },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    version = "*",
    opts = {
      current_line_blame = true,
    },
  },
}
