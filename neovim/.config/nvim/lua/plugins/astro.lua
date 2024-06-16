return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'astro' })
    end,
  },

  {
    'neovim/nvim-lspconfig',
    opts = {
      -- make sure mason installs the server
      servers = {
        astro = {},
      },
    },
  },

  {
    'stevearc/conform.nvim',
    optional = true,
    opts = {
      formatters_by_ft = {
        astro = { 'prettier' },
      },
    },
  },
}
