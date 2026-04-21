-- Use basedpyright (stricter, matches `mypy --strict`) for the LazyVim
-- lang.python extra. Must be set before the extra loads its plugin specs.
vim.g.lazyvim_python_lsp = "basedpyright"

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
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-python"] = {
          runner = "pytest",
          args = { "-v" },
          -- Resolve the project's venv (uv / poetry / plain .venv) per-file so
          -- tests run against installed deps instead of the system Python.
          python = function()
            local cwd = vim.fn.getcwd()
            local candidates = {
              cwd .. "/.venv/bin/python",
              cwd .. "/venv/bin/python",
            }
            for _, p in ipairs(candidates) do
              if vim.fn.executable(p) == 1 then
                return p
              end
            end
            return "python3"
          end,
        },
      },
    },
  },
}
