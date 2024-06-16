return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { 'php' })
    end,
  },
  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { 'intelephense', 'pint' })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        intelephense = {},
      },
    },
  },
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = {
      ---@type table<string, conform.FiletypeFormatter>
      formatters_by_ft = {
        ['php'] = { 'pint' },
      },
    },
  },
}
