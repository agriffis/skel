local Util = require('lazyvim.util')

return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      -- Disable autoformat by default because we enable selectively via editorconfig.
      --autoformat = false,
      format = {
        -- Eclipse formatter is slow, and the timeout can't be set per formatter.
        timeout_ms = 5000,
      },
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    keys = {
      -- Add ctrl-p as an alternate key for the file finder.
      { '<c-p>', Util.telescope('files'), desc = 'Find Files (root dir)' },

      -- Add bb as an alternate key for the buffers list.
      { '<leader>bb', '<cmd>Telescope buffers show_all_buffers=true<cr>', desc = 'Switch Buffer' },

      -- Search for current word with *
      { '<leader>*', Util.telescope('grep_string'), desc = 'Word (root dir)' },
    },
  },
}
