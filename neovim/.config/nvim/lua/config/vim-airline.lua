local my = require('my')

local M = {}

function M.config()
  vim.g.airline_powerline_fonts = 1
  vim.g.airline_left_sep = ''
  vim.g.airline_left_alt_sep = ''
  vim.g.airline_right_sep = ''
  vim.g.airline_right_alt_sep = ''

  -- https://github.com/vim-airline/vim-airline#smarter-tab-line
  vim.g['airline#extensions#tabline#enabled'] = 1
  vim.g['airline#extensions#tabline#formatter'] = 'short_path'
  vim.g['airline#extensions#tabline#left_sep'] = ''
  vim.g['airline#extensions#tabline#left_alt_sep'] = ''
  vim.g['airline#extensions#tabline#right_sep'] = ' '
  vim.g['airline#extensions#tabline#right_alt_sep'] = ' '
  vim.g['airline#extensions#tabline#buffer_idx_mode'] = 1

  -- Airline doesn't fully init when loaded. Hook on its actual init so we can
  -- patch populated tables.
  function AirlineFinal()
    vim.g.airline_symbols = my.merge(vim.g.airline_symbols, {
      branch = '',
      keymap = 'Keymap:',
      readonly = '',
      space = ' ',
      spell = 'SPELL',
      whitespace = '',
    })
  end
  vim.cmd([[
    autocmd User AirlineAfterInit call v:lua.AirlineFinal()
  ]])

  require('my').spacekeys({
    ['1'] = {'<Plug>AirlineSelectTab1', 'Switch to buffer 1'},
    ['2'] = {'<Plug>AirlineSelectTab2', 'Switch to buffer 2'},
    ['3'] = {'<Plug>AirlineSelectTab3', 'Switch to buffer 3'},
    ['4'] = {'<Plug>AirlineSelectTab4', 'Switch to buffer 4'},
    ['5'] = {'<Plug>AirlineSelectTab5', 'Switch to buffer 5'},
    ['6'] = {'<Plug>AirlineSelectTab6', 'Switch to buffer 6'},
    ['7'] = {'<Plug>AirlineSelectTab7', 'Switch to buffer 7'},
    ['8'] = {'<Plug>AirlineSelectTab8', 'Switch to buffer 8'},
    ['9'] = {'<Plug>AirlineSelectTab9', 'Switch to buffer 9'},
    ['0'] = {'<Plug>AirlineSelectTab0', 'Switch to buffer 10'},
  })

  -- Next and previous buffer
  vim.cmd([[
    nmap <tab> <Plug>AirlineSelectNextTab
    nmap <s-tab> <Plug>AirlineSelectPrevTab
  ]])
end

return M
