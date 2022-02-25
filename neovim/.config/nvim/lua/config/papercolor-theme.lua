local M = {}

function M.setup()
  vim.g.PaperColor_Theme_Options = {
    theme = {
      default = {
        transparent_background = 1,
        allow_bold = 1,
        allow_italic = 1,
      },
      ['default.light'] = {
        override = {
          color07 = {'#000000', '16'},
        }
      }
    }
  }
end

function M.config()
  vim.cmd([[
    augroup config_papercolor_theme
      autocmd!

      " Underlining doesn't look good in tmux, which changes the curly
      " underlines to plain. Instead rely on PaperColor to set the
      " background colors.
      autocmd ColorScheme PaperColor hi SpellBad cterm=NONE gui=NONE
      autocmd ColorScheme PaperColor hi SpellCap cterm=NONE gui=NONE
      autocmd ColorScheme PaperColor hi SpellRare cterm=NONE gui=NONE
      autocmd ColorScheme PaperColor hi link LspDiagnosticsUnderlineError SpellBad
      autocmd ColorScheme PaperColor hi link LspDiagnosticsUnderlineWarning SpellCap
      autocmd ColorScheme PaperColor hi link LspDiagnosticsUnderlineHint SpellRare
      autocmd ColorScheme PaperColor hi link LspDiagnosticsUnderlineInformation SpellRare
    augroup END
  ]])
end

return M
