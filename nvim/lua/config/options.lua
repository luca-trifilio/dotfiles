-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- mapleader is space (LazyVim default); maplocalleader defaults to backslash
-- which is awkward to reach. Use comma instead (unused by default besides
-- the low-value "repeat last f/t motion reversed").
vim.g.maplocalleader = ","

-- LazyVim disables wrap by default; enable it for text visualization
vim.opt.wrap = true
