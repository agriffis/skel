local Util = require('lazyvim.util')

return {
  { 'folke/flash.nvim', opts = { modes = { search = { enabled = false } } } },

  {
    'nvim-telescope/telescope.nvim',
    keys = {
      -- Add ctrl-p as an alternate key for the file finder.
      { '<c-p>', Util.telescope('files'), desc = 'Find Files (project)' },

      -- Replace <leader>ff to open in the cwd of the current file.
      {
        '<leader>ff',
        function()
          return Util.telescope('find_files', { cwd = vim.fn.expand('%:p:h') })()
        end,
        'Find Files (alongside)',
      },

      -- Add bb as an alternate key for the buffers list.
      { '<leader>bb', '<cmd>Telescope buffers show_all_buffers=true<cr>', desc = 'Switch Buffer' },

      -- Search for current word with *
      { '<leader>*', Util.telescope('grep_string'), desc = 'Word (root dir)' },
    },
  },
}
