return {
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local h = require('null-ls.helpers')
      local methods = require('null-ls.methods')

      -- There's a way to do this with jdtls eventually, which would be much faster:
      -- https://github.com/eclipse/eclipse.jdt.ls/pull/640
      local eclipse = {
        name = 'eclipse',
        filetypes = { 'java' },
        method = { methods.internal.FORMATTING },
        condition = function(utils)
          return utils.root_has_file { 'eclipse-formatter.ini' }
        end,
        generator = h.formatter_factory {
          command = function(params)
            return params.root .. '/bin/eclipse-formatter'
          end,
          args = { '--filter' },
          to_stdin = true,
          timeout = 5000, -- not working yet, https://github.com/jose-elias-alvarez/null-ls.nvim/discussions/706
        },
      }

      table.insert(opts.sources, eclipse)
    end,
  },
}
