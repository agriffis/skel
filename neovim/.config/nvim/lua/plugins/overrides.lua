local Util = require('lazyvim.util')

return {
  -- Disable lots of stuff.
  { 'goolord/alpha-nvim', enabled = false },
  {
    'folke/flash.nvim',
    opts = { modes = { char = { enabled = false }, search = { enabled = false } } },
  },
  { 'echasnovski/mini.indentscope', enabled = false },
  { 'echasnovski/mini.pairs', enabled = false },
  { 'hrsh7th/nvim-cmp', opts = { completion = { autocomplete = false } } },
  { 'RRethy/vim-illuminate', enabled = false },

  -- Disable the indent guides by default, but they can be toggled on.
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

  -- Change the default signs.
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        -- "Lower One Quarter Block"
        add = { text = '▊' }, -- 
        change = { text = '▊' }, -- 
        delete = { text = '󰞒' },
        topdelete = { text = '󰞕' },
        changedelete = { text = '▊' },
        untracked = { text = '▊' },
      },
    },
  },

  -- Modify keys for lsp to use fzf or avoid telescope.
  {
    'neovim/nvim-lspconfig',
    opts = function()
      -- keys.get() returns a singleton. We can load it here, make additions
      -- (which amount to changes since they come later in the list), and these
      -- will be applied when an LSP server attaches.
      local keys = require('lazyvim.plugins.lsp.keymaps').get()
      if require('lazyvim.util').has('fzf-lua') then
        vim.list_extend(keys, {
          { 'gd', function() require('fzf-lua').lsp_definitions() end, desc = 'Goto Definition', has = 'definition' },
          { 'gr', function() require('fzf-lua').lsp_references() end, desc = 'References' },
          { 'gI', function() require('fzf-lua').lsp_implementations() end, desc = 'Goto Implementation' },
          { 'gy', function() require('fzf-lua').lsp_typedefs() end, desc = 'Goto T[y]pe Definition' },
        })
      elseif not require('lazyvim.util').has('telescope.nvim') then
        vim.list_extend(keys, {
          { 'gd', vim.lsp.buf.definition, desc = 'Goto Definition', has = 'definition' },
          { 'gr', vim.lsp.buf.references, desc = 'References' },
          { 'gI', vim.lsp.buf.implementation, desc = 'Goto Implementation' },
          { 'gy', vim.lsp.buf.type_definition, desc = 'Goto T[y]pe Definition' },
        })
      end
    end,
  },

  -- Additional keys for telescope (assuming it isn't disabled by fzf.lua)
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
