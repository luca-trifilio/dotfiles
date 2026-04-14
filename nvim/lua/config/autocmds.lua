-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Remove LazyVim's wrap+spell autocmd for markdown (we handle wrap manually, no spell)
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Enable visual line wrapping in markdown without spellcheck
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Disable marksman LSP: obsidian.nvim handles wikilink resolution
vim.lsp.enable("marksman", false)
