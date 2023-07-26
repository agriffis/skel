-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function clear_augroup(s)
  vim.api.nvim_create_augroup(s, { clear = true })
end

local function clear_lazyvim_augroup(s)
  clear_augroup('lazyvim_' .. s)
end

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

-- Enable numbering when editing code
vim.api.nvim_create_autocmd('User', {
  group = MyGroup,
  pattern = 'Code',
  callback = function()
    vim.opt_local.number = true
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  group = MyGroup,
  pattern = '*',
  callback = function(ev)
    if ev.match ~= 'text' then
      vim.cmd([[doautocmd User Code]])
    end
  end,
})

-- Disable LazyVim spellcheck defaults
-- https://www.lazyvim.org/configuration/general#auto-commands
clear_lazyvim_augroup('wrap_spell')
