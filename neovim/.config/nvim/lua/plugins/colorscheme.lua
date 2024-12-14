local themer = require('themer')

return {
  {
    'NLKNguyen/papercolor-theme',
    init = function()
      vim.g.PaperColor_Theme_Options = {
        theme = {
          default = {
            transparent_background = 1,
            allow_bold = 1,
            allow_italic = 1,
          },
          ['default.light'] = {
            override = {
              color07 = { '#000000', '16' },
            },
          },
        },
      }
    end,
    config = function()
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
    end,
  },

  {
    'agriffis/alabaster.nvim',
    branch = 'agriffis',
    init = function()
      vim.g.alabaster_dim_comments = true
      vim.g.alabaster_transparent_background = true
    end,
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    --  opts = {
    --    transparent_background = true,
    --  },
  },

  {
    'olimorris/onedarkpro.nvim',
  },

  {
    'overcache/NeoSolarized',
  },

  {
    'folke/tokyonight.nvim',
    opts = {
      style = 'night',
      light_style = 'day',
      dim_inactive = true,

      on_colors = function(c)
        if vim.o.background == 'light' then
          -- Use white background instead of light gray.
          -- Darkened backgrounds use light gray instead of dark gray.
          local r = {
            [c.bg] = '#ffffff',
            [c.bg_dark] = c.bg,
          }
          for k, v in pairs(c) do
            c[k] = r[v] or v
          end
        end
      end,

      on_highlights = function(hl, c)
        -- Make the dividers more visible.
        -- We also set the character to a thicker bar in vim.opt.fillchars
        hl.WinSeparator = { fg = c.fg_gutter }

        -- Enable dim_inactive to work on gitsigns.
        -- https://github.com/folke/tokyonight.nvim/issues/326#issuecomment-2143501061
        hl.FoldColumn = { bg = 'none' }
        hl.SignColumn = { bg = 'none' }
      end,
    },
  },

  -- Configure LazyVim to load colorscheme via themer
  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = themer.setup,
    },
  },
}
