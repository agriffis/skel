return {
  'zbirenbaum/copilot.lua',
  opts = {
    should_attach = function()
      return vim.env.COPILOT_ATTACH == '1'
    end,
  },
}
