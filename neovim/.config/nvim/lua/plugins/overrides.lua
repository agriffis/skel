local Util = require('lazyvim.util')

return {
  -- Disable lots of stuff.
  {
    'LazyVim/LazyVim',
    opts = {
      news = { lazyvim = false, neovim = false },
    },
  },
  { 'goolord/alpha-nvim', enabled = false },
  { 'nvimdev/dashboard-nvim', enabled = false },
  {
    'folke/flash.nvim',
    opts = { modes = { char = { enabled = false }, search = { enabled = false } } },
  },
  { 'echasnovski/mini.indentscope', enabled = false },
  { 'echasnovski/mini.pairs', enabled = false },
  {
    'hrsh7th/nvim-cmp',
    opts = function(_, opts)
      opts.completion.autocomplete = false
      -- Don't replace normal vim completion.
      opts.mapping['<C-P>'] = nil
      opts.mapping['<C-N>'] = nil
    end,
  },
  { 'lukas-reineke/indent-blankline.nvim', enabled = false },
  { 'RRethy/vim-illuminate', enabled = false },
  { 'nvim-treesitter/nvim-treesitter-context', enabled = false },
  {
    'windwp/nvim-ts-autotag',
    enabled = false,
    opts = {
      autotag = {
        -- https://github.com/windwp/nvim-ts-autotag/issues/124
        -- https://github.com/windwp/nvim-ts-autotag/issues/125
        -- https://github.com/windwp/nvim-ts-autotag/issues/151
        enable_close_on_slash = false,
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
          {
            'gd',
            function()
              require('fzf-lua').lsp_definitions { jump_to_single_result = true }
            end,
            desc = 'Goto Definition',
            has = 'definition',
          },
          {
            'gr',
            function()
              require('fzf-lua').lsp_references { ignore_current_line = true }
            end,
            desc = 'References',
          },
          {
            'gI',
            function()
              require('fzf-lua').lsp_implementations { jump_to_single_result = true }
            end,
            desc = 'Goto Implementation',
          },
          {
            'gy',
            function()
              require('fzf-lua').lsp_typedefs()
            end,
            desc = 'Goto T[y]pe Definition',
          },
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

  -- Additional keys for neotree
  {
    'nvim-neo-tree/neo-tree.nvim',
    keys = {
      {
        '<leader>fe',
        function()
          require('neo-tree.command').execute { action = 'focus', dir = LazyVim.root() }
        end,
        desc = 'Explore project (NeoTree)',
      },
      {
        '<leader>fE',
        function()
          require('neo-tree.command').execute { action = 'focus', dir = vim.fn.expand('%:p:h') }
        end,
        desc = 'Explore current dir (NeoTree)',
      },
      { '<leader>e', '<leader>fe', desc = 'Explore project (NeoTree)', remap = true },
      { '<leader>E', '<leader>fE', desc = 'Explore current dir (NeoTree)', remap = true },
    },
  },
}
