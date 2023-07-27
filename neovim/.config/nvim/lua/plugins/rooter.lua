return {
  {
    'airblade/vim-rooter',
    init = function()
      vim.g.rooter_patterns = { '.git', '.project', '.hg', '.bzr', '.svn', 'package.json' }
      vim.g.rooter_silent_chdir = 1
    end,
  },
}
