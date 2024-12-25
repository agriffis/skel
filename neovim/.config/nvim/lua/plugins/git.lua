return {
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewFileHistory', 'DiffviewLog', 'DiffviewOpen' },
    keys = {
      { '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', desc = 'Diffview current file history' },
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview open' },
    },
  },

  -- Spiritual successor to fugitive (but still pretty raw).
  -- Main benefit is that it integrates with diffview.nvim.
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'ibhagwan/fzf-lua',
    },
    config = true,
    keys = {
      {
        '<leader>gg',
        function()
          require('neogit').open { kind = 'split' }
        end,
        desc = 'Neogit status',
      },
      {
        '<leader>gl',
        function()
          require('neogit').open { 'log', kind = 'split' }
        end,
        desc = 'Neogit log',
      },
      {
        '<leader>gf',
        -- This isn't working yet and I don't know why.
        function()
          local file = vim.fn.expand('%')
          require('neogit').action('log', 'log_current', { '--', file })
        end,
        desc = 'Neogit log (current file)',
      },
    },
  },

  -- mainly for :Gvdiffsplit but maybe could be done with neogit
  {
    'tpope/vim-fugitive',
  },

  -- not sure this is necessary with neogit
  --{
  --  'rbong/vim-flog',
  --  lazy = true,
  --  cmd = { 'Flog', 'Flogsplit', 'Floggit' },
  --  dependencies = {
  --    'tpope/vim-fugitive',
  --  },
  --  keys = {
  --    { '<leader>gl', '<cmd>Flog<cr>' },
  --  },
  --},

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      numhl = true, -- :Gitsigns toggle_numhl
      current_line_blame = true, -- :Gitsigns toggle_current_line_blame
    },
    keys = {
      {
        '<leader>ub',
        '<cmd>Gitsigns toggle_current_line_blame<cmd>',
        desc = 'Toggle current line blame',
      },
    },
  },

  {
    'isakbm/gitgraph.nvim',
    dependencies = {
      { 'sindrets/diffview.nvim' },
    },
    opts = {
      hooks = {
        -- Check diff of a commit
        on_select_commit = function(commit)
          vim.notify('DiffviewOpen ' .. commit.hash .. '^!')
          vim.cmd(':DiffviewOpen ' .. commit.hash .. '^!')
        end,
        -- Check diff from commit a -> commit b
        on_select_range_commit = function(from, to)
          vim.notify('DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
          vim.cmd(':DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
        end,
      },
      -- https://github.com/isakbm/gitgraph.nvim#use-custom-symbols
      -- https://github.com/kovidgoyal/kitty/pull/7681
      symbols = {
        merge_commit = '',
        commit = '',
        merge_commit_end = '',
        commit_end = '',
        GVER = '',
        GHOR = '',
        GCLD = '',
        GCRD = '╭',
        GCLU = '',
        GCRU = '',
        GLRU = '',
        GLRD = '',
        GLUD = '',
        GRUD = '',
        GFORKU = '',
        GFORKD = '',
        GRUDCD = '',
        GRUDCU = '',
        GLUDCD = '',
        GLUDCU = '',
        GLRDCL = '',
        GLRDCR = '',
        GLRUCL = '',
        GLRUCR = '',
      },
    },
    keys = {
      {
        '<leader>gl',
        function()
          require('gitgraph').draw({}, { all = true, max_count = 5000 })
        end,
        desc = 'GitGraph',
      },
    },
  },
}
