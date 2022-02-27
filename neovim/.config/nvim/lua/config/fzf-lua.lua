local M = {}

function M.config()
  local fzf = require('fzf-lua')

  fzf.setup({
    fzf_opts = {
      ['--ansi'] = '',
      ['--prompt'] = '> ',
      ['--info'] = 'inline',
      ['--height'] = '100%',
      ['--layout'] = 'reverse',
      ['--keep-right'] = '', -- https://github.com/ibhagwan/fzf-lua/issues/269
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
  })

  local function search_cword()
    fzf.live_grep({
      search = vim.fn.expand('<cword>'),
    })
  end

  require('my').spacekeys({
    b = {
      b = {'<cmd>FzfLua buffers<cr>', 'Choose from open buffers'},
    },
    f = {
      f = {
        function() fzf.files({cwd = vim.fn.expand('%:p:h')}) end,
        'Open file in current dir',
      },
      h = {'<cmd>FzfLua oldfiles<cr>', 'Open recent file'},
    },
    p = {
      -- This works without needing to find project root because of vim-rooter.
      f = {'<cmd>FzfLua files<cr>', 'Open file in project'},
    },
    s = {
      p = {'<cmd>FzfLua live_grep<cr>', 'Search project'},
      P = {search_cword, 'Search project for current word'},
      l = {'<cmd>FzfLua resume<cr>', 'Resume last search'},
    },
    ['/'] = {'<cmd>FzfLua live_grep<cr>', 'Search project'},
    ['*'] = {search_cword, 'Search project for current word'},
  })

  require('which-key').register({
    ['<c-p>'] = {'<cmd>FzfLua files<cr>', 'Open file in project'},
  })
end

return M
