return {
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      opts.inlay_hints.enabled = false
      vim.list_extend(opts.servers.tsserver.keys, {
        {
          '<leader>cR',
          function()
            vim.lsp.buf.code_action {
              apply = true,
              context = {
                only = { 'source.removeUnused.ts' },
                diagnostics = {},
              },
            }
          end,
          desc = 'Remove unused imports',
        },
      })
    end,
  },

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
