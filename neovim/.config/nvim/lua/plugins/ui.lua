return {
  -- Disable the dashboard thing
  {
    'goolord/alpha-nvim',
    enabled = false,
  },

  -- Disable the indent guides by default, but they can be toggled on
  {
    'lukas-reineke/indent-blankline.nvim',
    config = function(_, opts)
      require('indent_blankline').setup(opts)
      vim.cmd([[IndentBlanklineDisable!]])
    end,
    keys = {
      {
        '<leader>ui',
        function()
          vim.cmd([[IndentBlanklineToggle]])
        end,
        desc = 'Toggle indent guides',
      },
      {
        '<leader>uI',
        function()
          vim.cmd([[IndentBlanklineToggle!]])
        end,
        desc = 'Toggle indent guides (global)',
      },
    },
  },

  -- Disable the cute animated indent scope indicator
  {
    'echasnovski/mini.indentscope',
    enabled = false,
  },
}
