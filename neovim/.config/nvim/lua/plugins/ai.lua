local my = require('my')

return {
  {
    'zbirenbaum/copilot.lua',

    -- Install an editorconfig custom property that will attach copilot if true.
    -- https://neovim.io/doc/user/plugins.html#editorconfig-custom-properties
    init = function()
      require('editorconfig').properties.copilot = function(bufnr, val)
        vim.b[bufnr].editorconfig_copilot = my.is_enabled(val)
        -- If copilot has already tried to attach, then we need to try again.
        -- Don't use force = true, because we want should_attach to run so the
        -- default filetype matching applies.
        require('copilot.command').attach { bufnr = bufnr }
      end
    end,

    -- Prevent default copilot attachment, regardless of filetype, unless
    -- editorconfig has `copilot = true`. This will return false if editorconfig
    -- hasn't been processed yet for this file; in that case, the custom
    -- property handler will call back.
    opts = {
      should_attach = function(bufnr, bufname)
        local allowed_by_env = my.is_enabled(os.getenv('COPILOT_ATTACH'))
        local allowed_by_editorconfig = vim.b[bufnr].editorconfig_copilot
        return (allowed_by_env or allowed_by_editorconfig)
          and require('copilot.config.should_attach').default(bufnr, bufname)
      end,
    },
  },
}
