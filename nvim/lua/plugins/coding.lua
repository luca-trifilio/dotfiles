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
        -- NOTE: previously stopped Gradle daemons on VimLeavePre via `gradle --stop`.
        -- Removed: it could kill an in-flight conform spotlessApply on exit, orphaning a
        -- `.conform.<pid>.<file>.java` temp that then breaks javac with "duplicate class".
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
    "pwntester/octo.nvim",
    opts = {
      -- `github-personal` is an SSH config alias (see gitconfig/.gitconfig), not a
      -- real host. Octo reads it from `git remote get-url` (which applies git's
      -- insteadOf rewriting) and needs this mapping to resolve it back to github.com.
      ssh_aliases = { ["github-personal"] = "github.com" },
      -- Octo runs `gh` in a sandboxed job env that only whitelists GITHUB_TOKEN,
      -- not GH_TOKEN (see octo/gh/init.lua env_vars). Per-project .envrc files
      -- (e.g. homelab) export GH_TOKEN to pick a specific `gh` account, so forward
      -- it here under the name Octo actually reads, or it silently falls back to
      -- gh's default keyring account and fails on private repos.
      gh_env = function()
        return { GITHUB_TOKEN = vim.env.GH_TOKEN }
      end,
    },
  },
}
