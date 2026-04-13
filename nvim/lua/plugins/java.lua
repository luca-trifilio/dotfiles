return {
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
}
