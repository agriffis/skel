-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local my = require('my')

local format = function()
  require('lazyvim.plugins.lsp.format').format { force = true }
end

-- Disable line movement keys, because these happen by mistake when I press esc
-- followed by k/j.
vim.keymap.del({ 'n', 'i', 'v' }, '<a-k>')
vim.keymap.del({ 'n', 'i', 'v' }, '<a-j>')

-- Disable resize keys in favor of our own.
vim.keymap.del('n', '<c-up>')
vim.keymap.del('n', '<c-down>')
vim.keymap.del('n', '<c-left>')
vim.keymap.del('n', '<c-right>')

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
  c = {
    F = {
      function()
        require('typescript').actions.removeUnused { sync = true }
        require('typescript').actions.organizeImports { sync = true }
        format()
      end,
      'Remove/organize imports and reformat',
    },
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

-- while waiting for https://github.com/LazyVim/LazyVim/pull/1240
my.nmap('gd', '<cmd>lua vim.lsp.buf.definition<cr>', { desc = 'Goto Definition' })
my.nmap('gr', '<cmd>lua vim.lsp.buf.references<cr>', { desc = 'References' })
my.nmap('gI', '<cmd>lua vim.lsp.buf.implementation<cr>', { desc = 'Goto Implementation' })
my.nmap('gy', '<cmd>lua vim.lsp.buf.type_definition<cr>', { desc = 'Goto T[y]pe Definition' })

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

my.nmap('gw', 'v:lua.op_reformat_prose()', { desc = 'Reformat (80 columns)', expr = true })
my.xmap('gw', 'v:lua.op_reformat_prose()', { desc = 'Reformat (80 columns)', expr = true })
my.nmap('gwgw', "v:lua.op_reformat_prose() .. '_'", { desc = 'Reformat (80 columns)', expr = true })

-- Load a few personal things.
my.source(vim.fn.expand('~/.vimrc.mine'), { missing_ok = true })
