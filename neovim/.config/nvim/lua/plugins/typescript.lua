return {
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
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
}
