local my = require('my')

return {
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      vim.list_extend(
        opts.inlay_hints.exclude,
        { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
      )
    end,
  },

  -- project-wide TypeScript type-checking using the TypeScript compiler (tsc). It displays the
  -- type-checking results in a quickfix list and provides visual notifications about the progress
  -- and completion of type-checking.
  --
  -- Command is :TSC
  {
    'dmmulroy/tsc.nvim',
    -- https://github.com/dmmulroy/tsc.nvim?tab=readme-ov-file#configuration
    opts = {
      auto_start_watch_mode = true,
      use_trouble_qflist = true,
      use_diagnostics = false, -- default
    },
  },
}
