local M = {}

function M.config()
  vim.notify = require('notify')
  vim.notify.setup({
    stages = 'static',
  })
  -- https://github.com/rcarriga/nvim-notify/blob/master/README.md#highlights
  vim.cmd([[
    augroup config_notify
      autocmd!
      autocmd ColorScheme * hi! link NotifyINFOBorder Normal
      autocmd ColorScheme * hi! link NotifyINFOIcon Normal
      autocmd ColorScheme * hi! link NotifyINFOTitle Normal
      autocmd ColorScheme * hi! NotifyERRORBorder guifg=#F70067
      autocmd ColorScheme * hi! NotifyWARNBorder guifg=#F79000
    augroup END
  ]])
end

return M
