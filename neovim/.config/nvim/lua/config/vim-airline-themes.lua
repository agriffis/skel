local M = {}

function M.config()
  -- Airline doesn't know about PaperColorSlim.
  vim.cmd([[
    augroup my_vim_airline_themes
      autocmd!
      autocmd ColorScheme PaperColorSlim let g:airline_theme = 'papercolor'
    augroup END
  ]])
end

return M
