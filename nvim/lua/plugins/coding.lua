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
      on_attach = function()
        -- Stop Gradle daemons when leaving nvim (runs once, guarded by flag)
        if not vim.g._jdtls_vimleave_registered then
          vim.g._jdtls_vimleave_registered = true
          vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
              vim.fn.jobstart({ "gradle", "--stop" }, { detach = true })
            end,
          })
        end
      end,
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        spotless = {
          command = "./gradlew",
          args = function(self, ctx)
            return { "spotlessApply", "-PspotlessIdeHook=" .. ctx.filename, "--quiet" }
          end,
          stdin = false,
          cwd = require("conform.util").root_file({ "settings.gradle.kts", "build.gradle.kts", "build.gradle" }),
          require_cwd = true,
        },
      },
      formatters_by_ft = {
        java = { "spotless" },
      },
    },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "Format (Spotless)",
      },
    },
  },
  {
    "tpope/vim-fugitive",
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
