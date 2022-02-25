local M = {}

function M.config()
  require('which-key').setup()
  require('my').spacekeys({
    b = {
      name = 'Buffer operations',
      d = {'<cmd>bd<cr>', 'Delete current buffer'},
    },
    f = {
      name = 'File operations',
    },
    g = {
      name = 'Code operations',
    },
    p = {
      name = 'Project operations',
    },
    s = {
      name = 'Search operations',
      r = {'<cmd>%s/\\<<c-r>=expand("<cword>")<cr>\\>//g<left><left>', 'Global search and replace'},
    },
    t = {
      name = 'Toggles',
      f = {'<cmd>NvimTreeToggle<cr>', 'Toggle file explorer'},
    },
    w = {
      name = 'Window operations',
      c = {'<c-w>c', 'Close window'},
      h = {'<c-w>h', 'Switch to window left'},
      j = {'<c-w>j', 'Switch to window below'},
      k = {'<c-w>k', 'Switch to window above'},
      l = {'<c-w>l', 'Switch to window right'},
      s = {'<c-w>s', 'Split window into rows'},
      v = {'<c-w>v', 'Split window into columns'},
      H = {'<c-w>H', 'Move window to far left'},
      L = {'<c-w>L', 'Move window to far right'},
      J = {'<c-w>J', 'Move window to bottom'},
      K = {'<c-w>K', 'Move window to top'},
      o = {'<c-w>o', 'Close other windows'},
    },
    ['<space>'] = {'<cmd>nohl<cr>', 'Stop highlighting matches'},
    ['<tab>'] = {'<cmd>b#<cr>', 'Switch to previous buffer'},
  })
end

return M
