-- plugins.lua
--
-- Written in 2003-2022 by Aron Griffis <aron@arongriffis.com>
-- (originally as .vimrc)
--
-- To the extent possible under law, the author(s) have dedicated all copyright
-- and related and neighboring rights to this software to the public domain
-- worldwide. This software is distributed without any warranty.
--
-- CC0 Public Domain Dedication at
-- http://creativecommons.org/publicdomain/zero/1.0/
--------------------------------------------------------------------------------

local my = require('my')

-- Packer config
local config = {
  -- Move compilation output out of stow-managed dir
  -- (but still in default runtimepath)
  compile_path = vim.fn.expand('~/.local/share/nvim/site/plugin/packer_compiled.lua'),
  display = {
    open_fn = function()
      return require('packer.util').float {
        border = "rounded"
      }
    end,
  },
}

-- Packer plugins
local function plugins(use)
  vim.cmd([[
    augroup my_plugins
      autocmd!
    augroup END
  ]])

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup()
      require('my').spacekeys({
        b = {
          name = 'Buffer operations',
          d = {'<cmd>bd<cr>', 'Delete current buffer'},
        },
        f = {
          name = 'File operations',
        },
        g = {
          name = 'Code operations',
        },
        p = {
          name = 'Project operations',
        },
        s = {
          name = 'Search operations',
        },
        w = {
          name = 'Window operations',
          c = {'<c-w>c', 'Close window'},
          h = {'<c-w>h', 'Switch to window left'},
          j = {'<c-w>j', 'Switch to window below'},
          k = {'<c-w>k', 'Switch to window above'},
          l = {'<c-w>l', 'Switch to window right'},
          s = {'<c-w>s', 'Split window into rows'},
          v = {'<c-w>v', 'Split window into columns'},
          H = {'<c-w>H', 'Move window to far left'},
          L = {'<c-w>L', 'Move window to far right'},
          J = {'<c-w>J', 'Move window to bottom'},
          K = {'<c-w>K', 'Move window to top'},
          o = {'<c-w>o', 'Close other windows'},
        },
      })
    end
  }

  use {
    'vim-airline/vim-airline',
    requires = {'folke/which-key.nvim'},
    config = function()
      require('config.vim-airline').config()
      require('my').spacekeys({
        ['1'] = {'<Plug>AirlineSelectTab1', 'Switch to buffer 1'},
        ['2'] = {'<Plug>AirlineSelectTab2', 'Switch to buffer 2'},
        ['3'] = {'<Plug>AirlineSelectTab3', 'Switch to buffer 3'},
        ['4'] = {'<Plug>AirlineSelectTab4', 'Switch to buffer 4'},
        ['5'] = {'<Plug>AirlineSelectTab5', 'Switch to buffer 5'},
        ['6'] = {'<Plug>AirlineSelectTab6', 'Switch to buffer 6'},
        ['7'] = {'<Plug>AirlineSelectTab7', 'Switch to buffer 7'},
        ['8'] = {'<Plug>AirlineSelectTab8', 'Switch to buffer 8'},
        ['9'] = {'<Plug>AirlineSelectTab9', 'Switch to buffer 9'},
        ['0'] = {'<Plug>AirlineSelectTab0', 'Switch to buffer 10'},
      })
    end,
  }

  use {
    'vim-airline/vim-airline-themes',
    config = function() require('config.vim-airline-themes').config() end,
  }

  use {
    'Asheq/close-buffers.vim',
    requires = {'folke/which-key.nvim'},
    config = function()
      require('my').spacekeys({
        b = {
          D = {'<cmd>Bdelete hidden<cr>', 'Delete hidden buffers'},
          O = {'<cmd>Bdelete other<cr>', 'Delete other buffers'},
        },
      })
    end
  }

  use {
    'NLKNguyen/papercolor-theme',
    setup = function() require('config.papercolor-theme').setup() end,
  }

  use {
    'nanotech/jellybeans.vim',
    setup = function()
      vim.g.jellybeans_background_color = ''
      vim.g.jellybeans_background_color_256 = 'NONE'
    end,
  }

  use {
    'pappasam/papercolor-theme-slim',
    config = function() require('config.papercolor-theme-slim').config() end,
  }

  use {
    'norcalli/nvim-colorizer.lua',
    config = function()
      vim.opt.termguicolors = true
      require('colorizer').setup {'*', '!text'}
    end,
  }

  ----------------------------------------------------------------------
  -- global utilities
  ----------------------------------------------------------------------
  use {'tpope/vim-commentary'} -- gcc toggle comments
  use {'tpope/vim-fugitive'} -- :Gvdiffsplit
  use {'tpope/vim-rhubarb'} -- :Gbrowse for github
  use {'tpope/vim-surround'} -- dst ysiw<h1>

--use {
--  'junegunn/vim-easy-align',
--  config = function()
--    local my = require('my')
--    my.xmap('ga', '<Plug>(EasyAlign)')
--  end,
--}

  ----------------------------------------------------------------------
  -- projects
  ----------------------------------------------------------------------
  use {
    'airblade/vim-rooter',
    setup = function()
      vim.g.rooter_patterns = {'.git', '.project', '.hg', '.bzr', '.svn', 'package.json'}
      vim.g.rooter_silent_chdir = 1
    end,
  }

  use {'junegunn/fzf', run = './install --bin'}
  use {
    'ibhagwan/fzf-lua',
    requires = {'kyazdani42/nvim-web-devicons'},
    config = function()
      require('my').spacekeys({
        b = {
          b = {'<cmd>FzfLua <cr>', 'Choose from open buffers'},
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
    end,
  }

  ----------------------------------------------------------------------
  -- programming: lsp, tree-sitter, formatting
  ----------------------------------------------------------------------
  use {
    'neovim/nvim-lspconfig',
    setup = function() require('config.lsp').setup() end,
    config = function() require('config.lsp').config() end,
  }

  -- syntax hilighting via tree-sitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      vim.cmd('TSUpdate')
    end,
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'maintained',
        highlight = {enable = true},
        indent = {enable = true},
      }
    end,
  }

--  -- code formatting
--  use {'google/vim-maktaba'}
--  use {
--    'google/vim-glaive',
--    config = function()
--      vim.fn['glaive#Install']()
--    end,
--    requires = {'google/vim-maktaba'},
--  }
--  use {
--    'agriffis/vim-codefmt',
--    branch = 'scampersand',
--    requires = {'google/vim-glaive'},
--
--    config = function()
--      vim.cmd([[
--        Glaive codefmt plugin[mappings]
--      ]])
--
--      -- Extra setup for prettier
--      --
--      -- Don't do this unilaterally:
--      --   Glaive codefmt prettier_executable=`['yarn', 'prettier']`
--      -- because it's 6x slower (1.2s vs 0.2s) than the default
--      -- npx in vim-codefmt upstream. Unfortunately npx doesn't work with yarn
--      -- v2 pnp, but it does work fine with yarn in general.
--      if vim.fn.executable('proxier') == 1 then
--        vim.cmd([[
--          Glaive codefmt prettier_executable=`['proxier']`
--        ]])
--      end
--
--      -- Extra setup for zprint
--      --
--      -- Default formatting keys <leader>== and <leader>=b respect existing
--      -- newlines for minimal disruption. Extra formatting keys <leader>=+ and
--      -- <leader>++ and <leader>=B respect blank lines only.
--      vim.cmd([[
--        Glaive codefmt zprint_options=`[]`
--        function! RespectableZprint(respect, what) abort
--          if a:respect == 'nl'
--            Glaive codefmt zprint_options=`['{:style [:respect-nl]}']`
--          else
--            Glaive codefmt zprint_options=`['{:style [:respect-bl]}']`
--          endif
--          try
--            if a:what == 'buffer'
--              FormatCode zprint
--            else
--              exe "normal vaF:FormatLines zprint\<cr>"
--            endif
--          finally
--            Glaive codefmt zprint_options=`[]`
--          endtry
--        endfunction
--        autocmd FileType clojure nmap <buffer> <silent> <leader>== :call RespectableZprint('nl', 'fn')<cr>
--        autocmd FileType clojure nmap <buffer> <silent> <leader>=+ :call RespectableZprint('bl', 'fn')<cr>
--        autocmd FileType clojure nmap <buffer> <silent> <leader>++ :call RespectableZprint('bl', 'fn')<cr>
--        autocmd FileType clojure nmap <buffer> <silent> <leader>=b :call RespectableZprint('nl', 'buffer')<cr>
--        autocmd FileType clojure nmap <buffer> <silent> <leader>=B :call RespectableZprint('bl', 'buffer')<cr>
--      ]])
--    end,
--  }

  -- This is the official editorconfig plugin. There is also an alternative
  -- sgur/vim-editorconfig which used to be preferable because it was pure VimL
  -- whereas the official plugin required Python. Now the official plugin
  -- doesn't require Python, and it provides an API for fetching domain-specific
  -- keys, see :help editorconfig-advanced
  use {
    'editorconfig/editorconfig-vim',
    setup = function()
      vim.g.EditorConfig_exclude_patterns = {'fugitive://.*'}
      vim.g.EditorConfig_max_line_indicator = 'none'
    end,
    config = function()
      vim.cmd([[
        function! EditorConfigAutoformatHook(config)
          if has_key(a:config, 'autoformat') && exists(':AutoFormatBuffer')
            exec 'AutoFormatBuffer' a:config['autoformat']
          endif
          return 0
        endfunction
        call editorconfig#AddNewHook(function('EditorConfigAutoformatHook'))
      ]])
    end,
  }

  ----------------------------------------------------------------------
  -- Languages
  ----------------------------------------------------------------------

  -- HTML --------------------------------------------------------------
  -- Assume <p> will include closing </p> and content should be indented.
  -- If more are needed, this should be a comma-separated list.
  vim.g.html_indent_inctags = 'p,main'
  -- {'agriffis/vim-jinja'}
  -- {'mustache/vim-mustache-handlebars'}
  -- {'windwp/nvim-ts-autotag'}
  use {
    'agriffis/closetag.vim',
    config = function()
      vim.cmd([[
        augroup my_plugins
          " The closetag.vim script is kinda broken... it requires b:unaryTagsStack
          " per buffer but only sets it once, on script load.
          autocmd BufNewFile,BufReadPre * let b:unaryTagsStack=""
          autocmd BufNewFile,BufReadPre *.html,*.md let b:unaryTagsStack="area base br dd dt hr img input link meta param"
          autocmd FileType javascriptreact,markdown,xml let b:unaryTagsStack=""

          " Replace the default closetag maps with c-/ in insert mode only.
          autocmd FileType html,javascriptreact,markdown,vue,xml inoremap <buffer> <C-/> <C-r>=GetCloseTag()<CR>
        augroup END
      ]])
    end,
  }

  -- CSS ---------------------------------------------------------------
  vim.cmd([[
    augroup my_plugins
      autocmd BufNewFile,BufReadPost *.overrides,*.variables set ft=less
    augroup END
  ]])

  -- Markdown ----------------------------------------------------------
  -- vim bundles vim-markdown (by tpope)
  vim.g.markdown_fenced_languages = {'html', 'python', 'bash=sh', 'clojure', 'sql'}
  vim.g.markdown_minlines = 500
  -- {'jxnblk/vim-mdx-js'}

  -- JavaScript and Vue ------------------------------------------------
  vim.cmd([[
    augroup my_plugins
      autocmd BufNewFile,BufReadPost *.js set filetype=javascriptreact
      autocmd FileType vue setl comments=s:<!--,m:\ \ \ \ \ ,e:-->,s1:/*,mb:*,ex:*/,://
    augroup END
  ]])

  -- Java and Clojure --------------------------------------------------
  use {'tpope/vim-classpath'}
  use {'Olical/conjure'}
  use {
    'guns/vim-sexp',
    setup = function()
      vim.g.sexp_insert_after_wrap = 0
    end,
  }
  use {
    'tpope/vim-sexp-mappings-for-regular-people',
    config = function()
      vim.cmd([[
        function! MySexpMappings() abort
          nmap <buffer> ><  <Plug>(sexp_emit_head_element)
          nmap <buffer> <>  <Plug>(sexp_emit_tail_element)
          nmap <buffer> <<  <Plug>(sexp_capture_prev_element)
          nmap <buffer> >>  <Plug>(sexp_capture_next_element)
        endfunction
        augroup my_plugins
          autocmd FileType clojure,lisp,scheme call MySexpMappings()
        augroup END
      ]])
    end,
  }
end

-- Packer bootstrap
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local installed = vim.fn.isdirectory(install_path) == 1
local bootstrapped = false
if not installed then
  vim.fn.system {'git', 'clone', '--depth=1', 'https://github.com/wbthomason/packer.nvim', install_path}
  bootstrapped = vim.v.shell_error == 0
  if bootstrapped then
    vim.cmd('packadd packer.nvim')
    installed = true
  end
end

-- Packer init
if installed then
  local packer = require('packer')
  packer.init(config)
  packer.startup(plugins)

  -- Packer sync after bootstrap
  if bootstrapped then
    packer.sync()
  else
    -- Packer compile when out of date
    local plugins_lua = debug.getinfo(1, 'S').source:sub(2) -- trim leading @
    local stale = vim.fn.filereadable(config.compile_path) == 0 or
      vim.fn.getftime(plugins_lua) > vim.fn.getftime(config.compile_path)
    if stale then
      print "Compiling plugins"
      packer.compile()
    end

    -- Packer compile when this file is written. This just re-reads, it will
    -- rebuild thanks to stale check above.
    vim.cmd(string.format([[
        augroup reload_plugins_lua
          autocmd!
          autocmd BufWritePost %s,%s source %s
        augroup END
      ]],
      -- First match, abs path to this script.
      plugins_lua,
      -- Second match, absolute resolved path because this file is in two
      -- locations via symlink/stow, and I don't want to match on generic
      -- plugins.lua
      vim.fn.resolve(plugins_lua),
      -- What to load, don't use <afile> because that loads from both locations.
      plugins_lua
    ))
  end
end

return installed
