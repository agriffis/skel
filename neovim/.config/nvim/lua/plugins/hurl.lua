return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'hurl' })
    end,
  },

  {
    'jellydn/hurl.nvim',
    ft = 'hurl',
    opts = {
      mode = 'split', -- or popup
      formatters = {
        json = { 'jq' },
        html = { 'prettier', '--parser', 'html' },
      },
      show_notification = false,
      env_file = { 'hurl.env' },
      auto_close = false,
    },
    keys = {
      { '<leader>da', '<cmd>HurlRunnerAt<cr>', desc = 'Run current' },
      { '<leader>dA', '<cmd>HurlRunner<cr>', desc = 'Run all' },
      { '<leader>dC', '<cmd>HurlRunnerToEntry<cr>', desc = 'Run to cursor' },
    },
  },
}
