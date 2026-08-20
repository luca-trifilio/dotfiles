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

-- Enable visual line wrapping everywhere (LazyVim disables it by default; no spellcheck).
-- `wrap` is window-local, so FileType alone misses windows created after the buffer
-- (e.g. Octo diff panes). BufWinEnter/WinEnter catch the window itself.
-- Excluded filetypes keep nowrap on purpose: list/tree panes rely on horizontal truncation.
local nowrap_filetypes = {
  octo_panel = true,
  snacks_picker_list = true,
  ["neo-tree"] = true,
  NvimTree = true,
  TelescopePrompt = true,
  qf = true,
}

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
  group = vim.api.nvim_create_augroup("user_wrap", { clear = true }),
  callback = function()
    if nowrap_filetypes[vim.bo.filetype] then
      return
    end
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Disable marksman LSP: obsidian.nvim handles wikilink resolution
vim.lsp.enable("marksman", false)
