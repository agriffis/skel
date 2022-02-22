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
end

return M
