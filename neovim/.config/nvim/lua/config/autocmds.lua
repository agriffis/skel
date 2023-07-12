-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local MyGroup = vim.api.nvim_create_augroup('MyGroup', { clear = true })

-- When editing a file, always jump to the last cursor position.
-- This duplicates an autocmd provided by fedora, so clear that.
vim.api.nvim_create_augroup('fedora', { clear = true })
vim.api.nvim_create_autocmd('BufReadPost', {
  group = MyGroup,
  command = [[if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]],
})
vim.api.nvim_create_autocmd('BufReadPost', {
  group = MyGroup,
  pattern = 'COMMIT_EDITMSG',
  command = [[normal! gg]],
})

-- Disable autoformat per buffer, to be reenabled by editorconfig
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPre' }, {
  group = MyGroup,
  callback = function(event)
    vim.b[event.buf].autoformat = false
  end,
})
