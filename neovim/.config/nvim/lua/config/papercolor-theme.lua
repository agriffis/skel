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

return M
