-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local my = require('my')

local format = function()
  require('lazyvim.plugins.lsp.format').format { force = true }
end

my.spacekeys {
  -- while waiting for https://github.com/LazyVim/LazyVim/pull/1240
  g = {
    d = { vim.lsp.buf.definition, 'Goto Definition' },
    r = { vim.lsp.buf.references, 'References' },
    I = { vim.lsp.buf.implementation, 'Goto Implementation' },
    y = { vim.lsp.buf.type_definition, 'Goto T[y]pe Definition' },
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
  ['='] = {
    -- lazyvim: <leader>cf
    ['b'] = { format, 'Format buffer' },
  },
}

-- Paste over currently selected without yanking.
my.vmap('p', '"_dP')

-- Resize pane with arrows in normal mode.
-- For rightmost/bottommost pane, swap bindings so it feels right.
my.nmap(
  '<right>',
  'winnr() == winnr("l") ? ":vertical resize -1<cr>" : ":vertical resize +1<cr>"',
  { expr = true, desc = 'Resize window' }
)
my.nmap(
  '<left>',
  'winnr() == winnr("l") ? ":vertical resize +1<cr>" : ":vertical resize -1<cr>"',
  { expr = true, desc = 'Resize window' }
)
my.nmap(
  '<down>',
  'winnr() == winnr("j") ? ":resize -1<cr>" : ":resize +1<cr>"',
  { expr = true, desc = 'Resize window' }
)
my.nmap(
  '<up>',
  'winnr() == winnr("j") ? ":resize +1<cr>" : ":resize -1<cr>"',
  { expr = true, desc = 'Resize window' }
)

-- Move between buffers with tab and shift-tab.
my.nmap('<tab>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
my.nmap('<s-tab>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })

-- Insert path of current file on command-line with %/
my.cmap('%/', '<C-R>=expand("%:p:h")."/"<CR>', { silent = false })

-- Reformat current paragraph with 80 textwidth
my.operator_register('op_reformat_prose', function(type)
  -- Save textwidth then override.
  local tw_save = vim.opt.textwidth
  vim.opt.textwidth = 80

  -- Convert motion to visual.
  local commands = {
    char = [[`[v`]gw]],
    line = [[`[V`]gw]],
    block = [[`[\<c-v>`]gw]],
  }
  vim.cmd('noautocmd keepjumps normal! ' .. commands[type] .. 'gw')

  -- Restore textwidth.
  vim.opt.textwidth = tw_save
end)

my.nmap('gw', 'v:lua.op_reformat_prose()', { expr = true })
my.xmap('gw', 'v:lua.op_reformat_prose()', { expr = true })
my.nmap('gwgw', "v:lua.op_reformat_prose() .. '_'", { expr = true })

-- Load a few personal things.
my.source(vim.fn.expand('~/.vimrc.mine'), { missing_ok = true })
