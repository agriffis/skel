return {
  {
    'zbirenbaum/copilot.lua',
    init = function()
      require('editorconfig').properties.copilot = function(bufnr, val)
        vim.b[bufnr].copilot_should_attach = val == 'true'
        require('copilot.command').attach { bufnr = bufnr }
      end
    end,
    opts = {
      should_attach = function(bufnr, bufname)
        if not vim.b[bufnr].copilot_should_attach then
          return false
        end
        return require('copilot.config.should_attach').default(bufnr, bufname)
      end,
    },
  },
}
