return {
  {
    'airblade/vim-rooter',
    enabled = false,
    init = function()
      vim.g.rooter_patterns = {
        '.bzr',
        '.git',
        '.hg',
        '.project',
        '.svn',
        -- 'bb.edn',
        -- 'build.boot',
        'deps.edn',
        -- 'package.json',
        -- 'project.clj',
        -- 'shadow-cljs.edn',
      }
      vim.g.rooter_silent_chdir = 1
    end,
  },
}
