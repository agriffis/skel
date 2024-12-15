local my = require('my')
local Util = require('lazyvim.util')

return {
  { 'LazyVim/LazyVim', opts = { news = { lazyvim = false, neovim = false } } },

  {
    'folke/snacks.nvim',
    opts = {
      dashboard = { enabled = false },
      -- Disable word highlighting. This used to be document_highlight in the lsp config.
      words = { enabled = false },
      scroll = { enabled = false },
    },
  },

  {
    'folke/flash.nvim',
    opts = { modes = { char = { enabled = false }, search = { enabled = false } } },
  },

  {
    'hrsh7th/nvim-cmp',
    optional = true,
    opts = function(_, opts)
      -- Don't start completion until I press ctrl-space.
      opts.completion.autocomplete = false
      -- Don't replace normal vim ctrl-n ctrl-p completion.
      local cmp = require('cmp')
      opts.mapping['<C-n>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
        else
          fallback()
        end
      end
      opts.mapping['<C-p>'] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
        else
          fallback()
        end
      end
    end,
  },

  -- LazyVim switched from nvim-cmp to blink.cmp in v14
  {
    'saghen/blink.cmp',
    optional = true,
    opts = function(_, opts)
      -- Omit buffer from default sources, so we're only getting "smart"
      -- completions from LSP etc.
      opts.sources.default = my.filter(function(v)
        return v ~= 'buffer' and v ~= 'snippets'
      end, opts.sources.default)

      -- Don't show completion menu until I press ctrl-space.
      opts.completion.menu.auto_show = false

      -- This is essentially the default keymap from LazyVim but without the C-y map that I don't
      -- understand, and with this alternate tab map.
      opts.keymap = {
        preset = 'enter',

        -- Change tab to accept ghost text item.
        ['<Tab>'] = {
          'snippet_forward',
          function(cmp)
            local completion_list = require('blink.cmp.completion.list')
            if next(completion_list.items) then
              vim.schedule(function()
                completion_list.accept {
                  index = completion_list.selected_item_idx or 1,
                }
              end)
              return true
            end
          end,
          'fallback',
        },
      }
    end,
  },

  {
    'windwp/nvim-ts-autotag',
    -- enabled = false,
    opts = {
      autotag = {
        -- https://github.com/windwp/nvim-ts-autotag/issues/124
        -- https://github.com/windwp/nvim-ts-autotag/issues/125
        -- https://github.com/windwp/nvim-ts-autotag/issues/151
        enable_close_on_slash = false,
      },
    },
  },

  -- Don't highlight word under cursor.
  {
    'neovim/nvim-lspconfig',
    opts = {
      -- N.B. This setting no longer does anything. See config for snacks above, instead.
      -- https://github.com/LazyVim/LazyVim/issues/4777
      document_highlight = { enabled = false },
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
