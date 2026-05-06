-- Bruno (.bru) request file support via local tree-sitter-bru grammar.
--
-- Setup steps (one-time):
--   1. This file registers the parser and filetype automatically.
--   2. Open Neovim and run :TSInstall bru
--   3. Restart Neovim and open any .bru file.
--
-- The grammar lives at ~/Progetti/tree-sitter-bru.
-- Queries are symlinked from there into ~/.config/nvim/queries/bru/
-- (see bootstrap.sh or run manually:
--   ln -s ~/Progetti/tree-sitter-bru/queries ~/.config/nvim/queries/bru)

-- Filetype detection for .bru files
vim.filetype.add({ extension = { bru = "bru" } })

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Register the local grammar so :TSInstall bru works
      local ok, parsers = pcall(require, "nvim-treesitter.parsers")
      if ok then
        parsers.bru = {
          install_info = {
            path = vim.fn.expand("~/Progetti/tree-sitter-bru"),
            -- src/parser.c is pre-generated; set generate=true if you
            -- want nvim-treesitter to re-run `tree-sitter generate`
            -- after pulling grammar changes.
            generate = false,
          },
        }
      end

      opts.ensure_installed = opts.ensure_installed or {}
      -- Do NOT add "bru" to ensure_installed here; install manually
      -- with :TSInstall bru the first time so it doesn't block startup
      -- before the parser has been installed.

      return opts
    end,
  },
}
