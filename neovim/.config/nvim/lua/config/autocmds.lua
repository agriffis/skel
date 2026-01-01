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

-- Disable Fedora-provided autocmd to jump to last cursor position in file.
clear_augroup('fedora')

-- commented because this scrolls the diff buffer in diffview
--vim.api.nvim_create_autocmd('BufReadPost', {
--  group = MyGroup,
--  command = [[if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]],
--})
--vim.api.nvim_create_autocmd('BufReadPost', {
--  group = MyGroup,
--  pattern = 'COMMIT_EDITMSG',
--  command = [[normal! gg]],
--})

-- LazyVim equiv of above
clear_lazyvim_augroup('last_loc')

-- Enable permanent signcolumn when editing code.
local function hacking()
  --vim.opt_local.cursorline = true
  --vim.opt_local.number = true
  vim.opt_local.signcolumn = 'yes'
end

-- Hacking mode when LSP attaches.
vim.api.nvim_create_autocmd('User', { group = MyGroup, pattern = 'Code', callback = hacking })
require('snacks').util.lsp.on({}, function(buffer, client)
  if client.name ~= 'marksman' then
    vim.cmd([[doautocmd User Code]])
  end
end)

-- Some known filetypes for hacking, especially where the LSP takes a while to attach.
vim.api.nvim_create_autocmd(
  'FileType',
  { group = MyGroup, pattern = { 'clojure', 'java' }, callback = hacking }
)

-- Disable LazyVim spellcheck defaults
-- https://www.lazyvim.org/configuration/general#auto-commands
clear_lazyvim_augroup('wrap_spell')
