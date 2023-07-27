return {
  -- Disable telescope in favor of fzf
  { 'nvim-telescope/telescope.nvim', enabled = false },

  -- Enable fzf
  {
    'ibhagwan/fzf-lua',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
      { 'junegunn/fzf', build = './install --bin' },
    },
    opts = {
      winopts = {
        preview = {
          layout = 'vertical', -- default is 'flex'
        },
      },
      fzf_opts = {
        ['--ansi'] = '',
        ['--exact'] = '',
        ['--height'] = '100%',
        ['--info'] = 'inline',
        ['--keep-right'] = '', -- https://github.com/ibhagwan/fzf-lua/issues/269
        ['--layout'] = 'reverse',
        ['--prompt'] = '> ',
      },
      grep = {
        rg_opts = table.concat({
          '--column',
          '--line-number',
          '--no-heading',
          '--color=always',
          '--smart-case',
          '--max-columns=512',
          '-g !.git',
        }, ' '),
      },
    },
    -- stylua: ignore
    keys = {
      { '<leader>bb', function() require('fzf-lua').buffers() end, desc = 'Choose from open buffers' },
      { '<leader>ff', function() require('fzf-lua').files { cwd = vim.fn.expand('%:p:h') } end, desc = 'Open file in current dir', },
      { '<leader>fr', function() require('fzf-lua').oldfiles() end, desc = 'Open file in project', },
      -- Following work without needing to find project root because we're
      -- always in the project root thanks to vim-rooter.
      { '<c-p>', function() require('fzf-lua').files() end, desc = 'Open file in project', },
      { '<leader>sp', function() require('fzf-lua').live_grep() end, desc = 'Search project', },
      { '<leader>sP', function() require('fzf-lua').live_grep { search = vim.fn.expand('<cword>'), } end, desc = 'Search project (current word)', },
      { '<leader>/', function() require('fzf-lua').live_grep() end, desc = 'Search project' },
      { '<leader>?', function() require('fzf-lua').live_grep { cwd = vim.fn.expand('%:p:h') } end, desc = 'Search current dir' },
      { '<leader>*', function() require('fzf-lua').live_grep { search = vim.fn.expand('<cword>'), } end, desc = 'Search project (current word)', },
      { '<leader>sR', function() require('fzf-lua').resume() end, desc = 'Resume last search' },
    },
  },
}
