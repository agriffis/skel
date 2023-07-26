return {
  {
    'hrsh7th/nvim-cmp',
    opts = { completion = { autocomplete = false } },
  },

  -- Change the default signs to be a bit wider. "Left Three Quarters Block"
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '▊' },
        change = { text = '▊' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▊' },
        untracked = { text = '▊' },
      },
    },
  },
}
