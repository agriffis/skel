-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local my = require('my')
local wk = require('which-key')

-- Disable line movement keys, because these happen by mistake when I press esc
-- followed by k/j.
vim.keymap.del({ 'n', 'i', 'v' }, '<a-k>')
vim.keymap.del({ 'n', 'i', 'v' }, '<a-j>')

-- Disable "saner" behavior of n and N in favor of Vim defaults.
vim.keymap.del({ 'n', 'x', 'o' }, 'n')
vim.keymap.del({ 'n', 'x', 'o' }, 'N')

-- Disable ctrl-s for save.
vim.keymap.del({ 'i', 'x', 'n', 's' }, '<c-s>')

-- Disable "better" indenting.
vim.keymap.del('v', '<')
vim.keymap.del('v', '>')

wk.add {
  -- lazyvim: these are mapped to https://github.com/echasnovski/mini.bufremove which preserves
  -- the current window, but I'm not used to that.
  --{ '<leader>bD', '<cmd>bd!<cr>', desc = 'Delete buffer (force)' },
  --{ '<leader>bd', '<cmd>bd<cr>', desc = 'Delete buffer' },
  --{ '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Delete other buffers' },
  -- lazyvim: <leader>i conflicts with toggling indent guides
  { '<leader>up', vim.show_pos, desc = 'Inspect position' },
  { '<leader>wH', '<c-w>H', desc = 'Move window to far left' },
  { '<leader>wJ', '<c-w>J', desc = 'Move window to bottom' },
  { '<leader>wK', '<c-w>K', desc = 'Move window to top' },
  { '<leader>wL', '<c-w>L', desc = 'Move window to far right' },
  { '<leader>w_', '<c-w>_', desc = 'Max height' },
  { '<leader>wc', '<c-w>c', desc = 'Close window' },
  { '<leader>wh', '<c-w>h', desc = 'Go to window left' },
  { '<leader>wj', '<c-w>j', desc = 'Go to window below' },
  { '<leader>wk', '<c-w>k', desc = 'Go to window above' },
  { '<leader>wl', '<c-w>l', desc = 'Go to window right' },
  { '<leader>wo', '<c-w>o', desc = 'Close other windows' },
  { '<leader>ws', '<c-w>s', desc = 'Split window' },
  { '<leader>wv', '<c-w>v', desc = 'Split window vertically' },
  { '<leader>ww', '<c-w>w', desc = 'Switch to other window' },
  { '<leader>wx', '<c-w>x', desc = 'Swap current with next' },
  { '<leader>w|', '<c-w>|', desc = 'Max width' },
}

wk.add {
  -- lazyvim: these are mapped to <tab> but t is easier
  { '<leader>t1', '<cmd>1tabnext<cr>', { desc = 'Go to first tab' } },
  { '<leader>t2', '<cmd>2tabnext<cr>', { desc = 'Go to second tab' } },
  { '<leader>t3', '<cmd>3tabnext<cr>', { desc = 'Go to third tab' } },
  { '<leader>t4', '<cmd>4tabnext<cr>', { desc = 'Go to fourth tab' } },
  { '<leader>t5', '<cmd>5tabnext<cr>', { desc = 'Go to fifth tab' } },
  { '<leader>t6', '<cmd>6tabnext<cr>', { desc = 'Go to sixth tab' } },
  { '<leader>t7', '<cmd>7tabnext<cr>', { desc = 'Go to seventh tab' } },
  { '<leader>t8', '<cmd>8tabnext<cr>', { desc = 'Go to eighth tab' } },
  { '<leader>t9', '<cmd>9tabnext<cr>', { desc = 'Go to last tab' } },
  { '<leader>t]', '<cmd>tabnext<cr>', { desc = 'Next tab' } },
  { '<leader>t[', '<cmd>tabprevious<cr>', { desc = 'Previous tab' } },
  { '<leader>tt', '<c-tab>', { desc = 'Go to alternate tab' } },
  { '<leader>td', '<cmd>tabclose<cr>', { desc = 'Close tab' } },
  { '<leader>to', '<cmd>tabonly<cr>', { desc = 'Close other tabs' } },
}

vim.keymap.set('n', '=', 'gq', { desc = 'Format code', remap = true })

-- while waiting for https://github.com/LazyVim/LazyVim/pull/1240
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'References' })
vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { desc = 'Goto Implementation' })
vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, { desc = 'Goto T[y]pe Definition' })

-- Paste over currently selected without yanking.
vim.keymap.set('v', 'p', '"_dP')

-- Replace resize keys with our own.
-- Resize pane with ctrl-arrows in normal mode.
-- For rightmost/bottommost pane, swap bindings so it feels right.
--vim.keymap.set(
--  'n',
--  '<c-right>',
--  'winnr() == winnr("l") ? ":vertical resize -1<cr>" : ":vertical resize +1<cr>"',
--  { desc = 'Resize window', expr = true, silent = true }
--)
--vim.keymap.set(
--  'n',
--  '<c-left>',
--  'winnr() == winnr("l") ? ":vertical resize +1<cr>" : ":vertical resize -1<cr>"',
--  { desc = 'Resize window', expr = true, silent = true }
--)
--vim.keymap.set(
--  'n',
--  '<c-down>',
--  'winnr() == winnr("j") ? ":resize -1<cr>" : ":resize +1<cr>"',
--  { desc = 'Resize window', expr = true, silent = true }
--)
--vim.keymap.set(
--  'n',
--  '<c-up>',
--  'winnr() == winnr("j") ? ":resize +1<cr>" : ":resize -1<cr>"',
--  { desc = 'Resize window', expr = true, silent = true }
--)

-- Move between buffers with tab and shift-tab instead of H/L.
--vim.keymap.del('n', '<s-h>')
--vim.keymap.del('n', '<s-l>')
--vim.keymap.set(
--  'n',
--  '<tab>',
--  '<cmd>BufferLineCycleNext<cr>',
--  { desc = 'Next buffer', silent = true }
--)
--vim.keymap.set(
--  'n',
--  '<s-tab>',
--  '<cmd>BufferLineCyclePrev<cr>',
--  { desc = 'Prev buffer', silent = true }
--)

-- Insert path of current file on command-line with %/
vim.keymap.set('c', '%/', '<C-R>=expand("%:p:h")."/"<CR>')

-- Format code with =
vim.keymap.set('n', '=', 'gq', { desc = 'Format code', remap = true })
vim.keymap.set('n', '==', 'gqq', { desc = 'Format code', remap = true })
vim.keymap.set('x', '=', 'gq', { desc = 'Format code', remap = true })

-- Reformat current paragraph with 80 textwidth
my.operator_register('op_reformat_prose', function(type)
  -- Save textwidth then override.
  local tw_save = vim.opt.textwidth
  local ai_save = vim.opt.autoindent
  local inde_save = vim.opt.indentexpr
  vim.opt.textwidth = 80
  vim.opt.autoindent = true
  vim.opt.indentexpr = 'indent()'
  -- Convert motion to visual.
  local commands = {
    char = '`[v`]',
    line = '`[V`]',
    block = '`[\\<c-v>`]',
  }
  vim.cmd('noautocmd keepjumps normal! ' .. commands[type] .. 'gw')
  -- Restore textwidth.
  vim.opt.textwidth = tw_save
  vim.opt.autoindent = ai_save
  vim.opt.indentexpr = inde_save
end)
vim.keymap.set(
  'n',
  'gW',
  'v:lua.op_reformat_prose()',
  { desc = 'Reformat (80 columns)', expr = true, silent = true }
)
vim.keymap.set(
  'x',
  'gW',
  'v:lua.op_reformat_prose()',
  { desc = 'Reformat (80 columns)', expr = true, silent = true }
)
vim.keymap.set(
  'n',
  'gWgW',
  "v:lua.op_reformat_prose() .. '_'",
  { desc = 'Reformat (80 columns)', expr = true, silent = true }
)
vim.keymap.set(
  'n',
  'gWW',
  "v:lua.op_reformat_prose() .. '_'",
  { desc = 'Reformat (80 columns)', expr = true, silent = true }
)

-- Load a few personal things.
my.source(vim.fn.expand('~/.vimrc.mine'), { missing_ok = true })
