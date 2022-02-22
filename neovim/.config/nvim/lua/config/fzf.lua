local M = {}

function M.setup()
  function build_fzf_quickfix_list(lines)
    vim.fn.setqflist(vim.fn.map(vim.fn.copy(lines), '{ "filename": v:val }'))
    vim.cmd([[copen | cc]])
  end

  vim.g.fzf_action = {
    ['ctrl-q'] = build_fzf_quickfix_list,
    ['ctrl-t'] = 'tab split',
    ['ctrl-x'] = 'split',
    ['ctrl-v'] = 'vsplit',
  }

  vim.g.fzf_colors = {
    ['fg'] =      {'fg', 'Normal'},
    ['bg'] =      {'bg', 'Normal'},
    ['hl'] =      {'fg', 'Comment'},
    ['fg+'] =     {'fg', 'CursorLine', 'CursorColumn', 'Normal'},
    ['bg+'] =     {'bg', 'CursorLine', 'CursorColumn'},
    ['hl+'] =     {'fg', 'Statement'},
    ['info'] =    {'fg', 'PreProc'},
    ['border'] =  {'fg', 'Ignore'},
    ['prompt'] =  {'fg', 'Conditional'},
    ['pointer'] = {'fg', 'Exception'},
    ['marker'] =  {'fg', 'Keyword'},
    ['spinner'] = {'fg', 'Label'},
    ['header'] =  {'fg', 'Comment'},
  }

  vim.g.fzf_history_dir = '~/.vim/fzf-history'

  function fzfProjectRg(query, fullscreen)
    local command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case --hidden -- %s || true'
    local initial_command = string.format(command_fmt, vim.fn.shellescape(query))
    local reload_command = string.format(command_fmt, '{q}')
    -- We used to pass 'dir': projectroot#guess() here, but since vim-rooter
    -- always changes directory for us, the current working dir is fine.
    local spec = {
      dir = vim.fn.getcwd(),
      options = {'--phony', '--query', query, '--bind', 'change:reload:' .. reload_command},
    }
    vim.fn['fzf#vim#grep'](initial_command, 1, vim.fn['fzf#vim#with_preview'](spec), fullscreen)
  end

  vim.cmd([[
    command! -bang ProjectFiles call fzf#vim#files(getcwd(), fzf#vim#with_preview(), <bang>0)
    command! -bang -nargs=* ProjectRg call v:lua.fzfProjectRg(<q-args>, <bang>0)
  ]])

  require('my').spacekeys({
    b = {
      b = {'<cmd>Buffers<cr>', 'Choose from open buffers'},
    },
    f = {
      f = {'<cmd>FZF <c-r>=expand("%:p:h")<cr><cr>', 'Open file in current dir'},
      g = {'<cmd>GFiles?<cr>', 'Open modified file (git)'},
      h = {'<cmd>History<cr>', 'Open recent file'},
    },
    p = {
      f = {'<cmd>ProjectFiles<cr>', 'Find file in project'},
    },
    s = {
      p = {'<cmd>ProjectRg<cr>', 'Search in project'},
      P = {'<cmd>ProjectRg <c-r>=expand("<cword>")<cr><cr>', 'Search in project for cursor word'},
    },
    ['/'] = {'<cmd>ProjectRg<cr>', 'Search in project'},
    ['*'] = {'<cmd>ProjectRg <c-r>=expand("<cword>")<cr><cr>', 'Search in project for cursor word'},
  })

  require('my').nmap('<c-p>', ':ProjectFiles<cr>')
end

return M
