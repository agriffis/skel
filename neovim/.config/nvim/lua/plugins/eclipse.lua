return {
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = {
      format = {
        -- Eclipse formatter is slow, and the timeout can't be set per formatter.
        timeout_ms = 5000,
      },
      formatters = {
        eclipse = {
          -- There's a way to do this with jdtls eventually, which would be much faster:
          -- https://github.com/eclipse/eclipse.jdt.ls/pull/640
          cwd = require('conform.util').root_file { 'eclipse-formatter.ini' },
          require_cwd = true,
          command = './bin/eclipse-formatter',
          args = { '--filter' },
        },
      },
      formatters_by_ft = {
        java = { 'eclipse' },
      },
    },
  },

  {
    'mfussenegger/nvim-jdtls',
    opts = function(_, opts)
      opts.cmd = { vim.fn.exepath('jdtls'), '-Djava.compile.nullAnalysis.mode=automatic' }
    end,
  },
}
