local my = require('my')

return {
  { 'LazyVim/LazyVim', opts = { news = { lazyvim = false, neovim = false } } },

  {
    'folke/snacks.nvim',
    opts = {
      dashboard = { enabled = false },
      indent = { enabled = false },
      scroll = { enabled = false },
    },
  },

  -- Show hidden files by default.
  -- https://github.com/LazyVim/LazyVim/discussions/6807#discussioncomment-15038023
  {
    'folke/snacks.nvim',
    opts = {
      picker = {
        hidden = true,
        sources = {
          files = {
            hidden = true,
          },
        },
      },
    },
  },

  {
    'folke/snacks.nvim',
    keys = {
      { '<c-p>', LazyVim.pick('files', { root = true }), desc = 'Find Files (Root Dir)' },
      {
        '<leader>ff',
        function()
          return LazyVim.pick.open('files', { cwd = vim.fn.expand('%:p:h') })
        end,
        desc = 'Find Files (cwd)',
      },
      {
        '<leader>*',
        function()
          return LazyVim.pick.open('grep_word')
        end,
        desc = 'Word (Root Dir)',
        mode = { 'n', 'x' },
      },
      -- duplicated from git.lua for now
      { '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', desc = 'Diffview current file history' },
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview open' },
    },
  },

  -- https://github.com/LazyVim/LazyVim/discussions/6787#discussioncomment-14978197
  --{
  --  'ibhagwan/fzf-lua',
  --  optional = true,
  --  keys = {
  --    {
  --      '<leader>ff',
  --      function()
  --        return LazyVim.pick.open('files', { cwd = vim.fn.expand('%:p:h') })
  --      end,
  --      desc = 'Find Files (cwd)',
  --    },
  --    {
  --      '<leader>*',
  --      function()
  --        -- This is different from snacks which is grep_word
  --        return LazyVim.pick.open('grep_cword')
  --      end,
  --      desc = 'Word (Root Dir)',
  --      mode = { 'n', 'x' },
  --    },
  --  },
  --},

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
        return v ~= 'buffer'
      end, opts.sources.default)

      -- Don't show completion menu until I press ctrl-space.
      opts.completion.menu.auto_show = false
      opts.completion.ghost_text.show_with_menu = false

      -- Don't consider ghost text visible.
      local function is_open()
        return require('blink.cmp.completion.windows.menu').win:is_open()
        -- or require('blink.cmp.completion.windows.ghost_text').is_open()
      end
      local function if_open_then(cmd)
        return function(cmp)
          return is_open() and cmp[cmd]()
        end
      end
      local function show_menu()
        if is_open() then
          return
        end
        vim.schedule(function()
          -- require('blink.cmp.completion.windows.menu').auto_show = true
          require('blink.cmp.completion.trigger').show {
            force = true,
            trigger_kind = 'manual',
          }
        end)
        return true
      end

      opts.keymap = {
        preset = 'none',
        ['<C-space>'] = { show_menu, 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<CR>'] = { if_open_then('accept'), 'fallback' },
        ['<Tab>'] = { 'accept', 'fallback' },
        ['<Up>'] = { if_open_then('select_prev'), 'fallback' },
        ['<Down>'] = { if_open_then('select_next'), 'fallback' },
        ['<C-p>'] = { if_open_then('select_prev'), 'fallback' },
        ['<C-n>'] = { if_open_then('select_next'), 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
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

  -- Replace mini.pairs with nvim-autopairs
  -- https://github.com/LazyVim/LazyVim/discussions/2248
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'nvim-mini/mini.pairs',
    enabled = false,
  },
}
