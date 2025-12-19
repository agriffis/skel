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
  -- lazyvim: some of these are mapped to <leader><tab> but t is easier
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
  { '<leader>tt', '<cmd>tabnext #<cr>', { desc = 'Alternate tab' } },
  { '<leader>td', '<cmd>tabclose<cr>', { desc = 'Close tab' } },
  { '<leader>to', '<cmd>tabonly<cr>', { desc = 'Close other tabs' } },
}

-- while waiting for https://github.com/LazyVim/LazyVim/pull/1240
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'References' })
vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { desc = 'Goto Implementation' })
vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, { desc = 'Goto T[y]pe Definition' })

-- Paste over currently selected without yanking.
vim.keymap.set('v', 'p', '"_dP')

-- Insert path of current file on command-line with %/
vim.keymap.set('c', '%/', '<C-R>=expand("%:p:h")."/"<CR>')

-- Format code with =
--vim.keymap.set({ 'n', 'x' }, '=', 'gq', { desc = 'Format code', remap = true })
--vim.keymap.set('n', '==', 'gqq', { desc = 'Format code', remap = true })

-- Reformat code with alternate formatter with <leader>=1, <leader>=2, etc.
for i = 1, 9 do
  my.operator_register('op_reformat_code_alt_' .. i, {
    setup = function()
      local conform = require('conform')
      local saved = {
        formatters_by_ft = conform.formatters_by_ft,
      }
      -- Our alternate formatters are stored in the opts for conform.nvim, and we
      -- have to fetch them from there because they don't carry into conform.
      local alt_formatters = LazyVim.opts('conform.nvim').formatters_by_ft_alt
      conform.formatters_by_ft = {}
      for k, v in pairs(alt_formatters) do
        conform.formatters_by_ft[k] = v[i]
      end
      return saved
    end,
    execute = 'gq',
    cleanup = function(saved)
      local conform = require('conform')
      conform.formatters_by_ft = saved.formatters_by_ft
    end,
  })
  vim.keymap.set(
    { 'n', 'x' },
    '<leader>=' .. i,
    'v:lua.op_reformat_code_alt_' .. i .. '()',
    { desc = 'Format code (alt ' .. i .. ')', expr = true, silent = true }
  )
  vim.keymap.set(
    'n',
    '<leader>=' .. i .. i,
    'v:lua.op_reformat_code_alt_' .. i .. "() .. '_'",
    { desc = 'Format code (alt ' .. i .. ')', expr = true, silent = true }
  )
end

-- Reformat current paragraph with 80 textwidth
my.operator_register('op_reformat_prose', {
  setup = function()
    local saved = {
      textwidth = vim.opt.textwidth,
      autoindent = vim.opt.autoindent,
      indentexpr = vim.opt.indentexpr,
    }
    vim.opt.textwidth = 80
    vim.opt.autoindent = true
    vim.opt.indentexpr = 'indent()'
    return saved
  end,
  execute = 'gw',
  cleanup = function(saved)
    vim.opt.textwidth = saved.textwidth
    vim.opt.autoindent = saved.autoindent
    vim.opt.indentexpr = saved.indentexpr
  end,
})
vim.keymap.set(
  { 'n', 'x' },
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

-- Load a few personal things.
my.source(vim.fn.expand('~/.vimrc.mine'), { missing_ok = true })
