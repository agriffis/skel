-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local my = require('my')

-- Disable line movement keys, because these happen by mistake when I press esc
-- followed by k/j.
vim.keymap.del({ 'n', 'i', 'v' }, '<a-k>')
vim.keymap.del({ 'n', 'i', 'v' }, '<a-j>')

-- Disable tab movement keys in favor of tab/shift-tab.
vim.keymap.del('n', '<s-h>')
vim.keymap.del('n', '<s-l>')

-- Disable "saner" behavior of n and N in favor of Vim defaults.
vim.keymap.del({ 'n', 'x', 'o' }, 'n')
vim.keymap.del({ 'n', 'x', 'o' }, 'N')

-- Disable "better" indenting.
vim.keymap.del('v', '<')
vim.keymap.del('v', '>')

-- Disable weird keys for accessing location/quickfix.
vim.keymap.del('n', '<leader>xl')
vim.keymap.del('n', '<leader>xq')

my.spacekeys {
  b = {
    -- lazyvim: these are mapped to https://github.com/echasnovski/mini.bufremove which preserves
    -- the current window, but I'm not used to that.
    d = { '<cmd>bd<cr>', 'Delete buffer' },
    D = { '<cmd>bd!<cr>', 'Delete buffer (force)' },
    o = { '<cmd>BufferLineCloseOthers<cr>', 'Delete other buffers' },
  },
  u = {
    -- lazyvim: <leader>i conflicts with toggling indent guides
    p = { vim.show_pos, 'Inspect position' },
  },
  w = {
    ['+'] = { '<c-w>+', 'Increase height' },
    ['-'] = { '<c-w>-', 'Decrease height' },
    ['>'] = { '<c-w>>', 'Increase width' },
    ['<'] = { '<c-w><', 'Decrease width' },
    ['_'] = { '<c-w>_', 'Max height' },
    ['|'] = { '<c-w>|', 'Max width' },
    ['='] = { '<c-w>=', 'Equally high and wide' },
    c = { '<c-w>c', 'Close window' },
    h = { '<c-w>h', 'Go to window left' },
    H = { '<c-w>H', 'Move window to far left' },
    j = { '<c-w>j', 'Go to window below' },
    J = { '<c-w>J', 'Move window to bottom' },
    k = { '<c-w>k', 'Go to window above' },
    K = { '<c-w>K', 'Move window to top' },
    l = { '<c-w>l', 'Go to window right' },
    L = { '<c-w>L', 'Move window to far right' },
    o = { '<c-w>o', 'Close other windows' },
    s = { '<c-w>s', 'Split window' },
    T = { '<c-w>T', 'Break out into a new tab' },
    v = { '<c-w>v', 'Split window vertically' },
    w = { '<c-w>w', 'Switch to other window' },
    x = { '<c-w>x', 'Swap current with next' },
  },
  -- lazyvim: <leader>ur is unwieldy
  ['<space>'] = {
    '<cmd>nohlsearch<bar>diffupdate<bar>normal! <c-l><cr>',
    'clear hlsearch / diff update / redraw',
  },
  -- lazyvim: <leader>` is unwieldy
  ['<tab>'] = { '<cmd>b#<cr>', 'Switch to previous buffer' },
}

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
vim.keymap.set(
  'n',
  '<c-right>',
  'winnr() == winnr("l") ? ":vertical resize -1<cr>" : ":vertical resize +1<cr>"',
  { desc = 'Resize window', expr = true, silent = true }
)
vim.keymap.set(
  'n',
  '<c-left>',
  'winnr() == winnr("l") ? ":vertical resize +1<cr>" : ":vertical resize -1<cr>"',
  { desc = 'Resize window', expr = true, silent = true }
)
vim.keymap.set(
  'n',
  '<c-down>',
  'winnr() == winnr("j") ? ":resize -1<cr>" : ":resize +1<cr>"',
  { desc = 'Resize window', expr = true, silent = true }
)
vim.keymap.set(
  'n',
  '<c-up>',
  'winnr() == winnr("j") ? ":resize +1<cr>" : ":resize -1<cr>"',
  { desc = 'Resize window', expr = true, silent = true }
)

-- Move between buffers with tab and shift-tab.
vim.keymap.set(
  'n',
  '<tab>',
  '<cmd>BufferLineCycleNext<cr>',
  { desc = 'Next buffer', silent = true }
)
vim.keymap.set(
  'n',
  '<s-tab>',
  '<cmd>BufferLineCyclePrev<cr>',
  { desc = 'Prev buffer', silent = true }
)

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
  vim.opt.textwidth = 80
  -- Convert motion to visual.
  local commands = {
    char = '`[v`]',
    line = '`[V`]',
    block = '`[\\<c-v>`]',
  }
  vim.cmd('noautocmd keepjumps normal! ' .. commands[type] .. 'gw')
  -- Restore textwidth.
  vim.opt.textwidth = tw_save
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
