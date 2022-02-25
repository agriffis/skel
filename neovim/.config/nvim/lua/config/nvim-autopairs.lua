local M = {}

function M.config()
  local npairs = require('nvim-autopairs')
  npairs.setup({
    check_ts = true,
    disable_filetype = {
      '', 'markdown', 'text', -- plain text
      'TelescopePrompt', -- default
    },
  })
  npairs.add_rules(require('nvim-autopairs.rules.endwise-lua'))
end

return M

