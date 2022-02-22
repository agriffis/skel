local M = {}

function M.config()
  vim.cmd([[
    augroup my_papercolor_theme_slim
      autocmd!

      " https://github.com/pappasam/papercolor-theme-slim#transparent-background
      autocmd ColorScheme PaperColorSlim hi Normal guibg=none

      " Underlining doesn't look good in tmux, which changes the curly
      " underlines to plain. Instead rely on PaperColor to set the
      " background colors.
      autocmd ColorScheme PaperColorSlim hi SpellBad cterm=NONE gui=NONE
      autocmd ColorScheme PaperColorSlim hi SpellCap cterm=NONE gui=NONE
      autocmd ColorScheme PaperColorSlim hi SpellRare cterm=NONE gui=NONE
      autocmd ColorScheme PaperColorSlim hi link LspDiagnosticsUnderlineError SpellBad
      autocmd ColorScheme PaperColorSlim hi link LspDiagnosticsUnderlineWarning SpellCap
      autocmd ColorScheme PaperColorSlim hi link LspDiagnosticsUnderlineHint SpellRare
      autocmd ColorScheme PaperColorSlim hi link LspDiagnosticsUnderlineInformation SpellRare

      " Airline doesn't know about PaperColorSlim.
      autocmd ColorScheme PaperColorSlim let g:airline_theme = 'papercolor'
    augroup END

    " In case the theme is already set?
    if exists('g:colors_name') && g:colors_name == 'PaperColorSlim'
      let g:airline_theme = 'papercolor'
    endif
  ]])
end

return M
