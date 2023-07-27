local function search_cword()
  require('fzf-lua').live_grep {
    search = vim.fn.expand('<cword>'),
  }
end

local function files_cwd()
  require('fzf-lua').files { cwd = vim.fn.expand('%:p:h') }
end

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
    keys = {
      { '<leader>bb', '<cmd>FzfLua buffers<cr>', desc = 'Choose from open buffers' },
      { '<leader>ff', files_cwd, desc = 'Open file in current dir' },
      { '<leader>fr', '<cmd>FzfLua oldfiles<cr>', desc = 'Open recent file' },
      -- This works without needing to find project root because we're always
      -- in the project root thanks to vim-rooter.
      { '<leader><space>', '<cmd>FzfLua files<cr>', desc = 'Open file in project' },
      { '<leader>sp', '<cmd>FzfLua live_grep<cr>', desc = 'Search project' },
      { '<leader>sP', search_cword, desc = 'Search project (current word)' },
      { '<leader>/', '<cmd>FzfLua live_grep<cr>', desc = 'Search project' },
      { '<leader>*', search_cword, desc = 'Search project (current word)' },
      { '<leader>sR', '<cmd>FzfLua resume<cr>', desc = 'Resume last search' },
    },
  },
}
