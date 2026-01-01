return {
  {
    'zbirenbaum/copilot.lua',

    -- Install an editorconfig custom property that will attach copilot if true.
    -- https://neovim.io/doc/user/plugins.html#editorconfig-custom-properties
    init = function()
      require('editorconfig').properties.copilot = function(bufnr, val)
        vim.b[bufnr].copilot_should_attach = val == 'true'
        require('copilot.command').attach { bufnr = bufnr }
      end
    end,

    -- Prevent default copilot attachment, regardless of filetype, unless
    -- editorconfig has `copilot = true`. This will return false if editorconfig
    -- hasn't been processed yet for this file; in that case, the custom
    -- property handler will call back.
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
