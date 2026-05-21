-- Bruno (.bru) request file — tree-sitter highlighting
--
-- Loads the parser directly via Neovim's native API, bypassing
-- nvim-treesitter's install mechanism entirely.  No :TSInstall needed.
--
-- To rebuild the parser after grammar changes:
--   cd ~/Progetti/tree-sitter-bru
--   npm run build && ./node_modules/.bin/tree-sitter build --output bru.so .

local parser_path = vim.fn.expand("~/Progetti/tree-sitter-bru/bru.so")

-- 1. Register the filetype
vim.filetype.add({ extension = { bru = "bru" } })

-- 2. Load the compiled parser and wire up highlighting + injections
vim.api.nvim_create_autocmd("FileType", {
  pattern = "bru",
  callback = function(ev)
    local ok, err = pcall(vim.treesitter.language.add, "bru", {
      path = parser_path,
    })
    if not ok then
      vim.notify("[bru] parser not loaded: " .. err, vim.log.levels.WARN)
      return
    end
    vim.treesitter.start(ev.buf, "bru")
  end,
})

return {}
