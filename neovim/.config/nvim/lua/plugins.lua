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

-- Packer config.
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
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Discoverable key binding manager. Individual plugin configs add their own
  -- bindings.
  use {
    'folke/which-key.nvim',
    config = function() require('config.which-key').config() end,
  }

  -- Status line. Consider replacing with LuaLine eventually.
  use {
    'vim-airline/vim-airline',
    wants = {'which-key.nvim'}, -- might not be effective #615
    config = function() require('config.vim-airline').config() end,
  }
  use {
    'vim-airline/vim-airline-themes',
    wants = {'vim-airline'}, -- might not be effective #615
    config = function() require('config.vim-airline-themes').config() end,
  }

  -- File explorer.
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {'kyazdani42/nvim-web-devicons'},
    wants = {'which-key.nvim'}, -- might not be effective #615
    config = function() require('config.nvim-tree').config() end,
  }

  -- Notifications.
  use {
    'rcarriga/nvim-notify',
    config = function() require('config.notify').config() end,
  }

  -- Themes.
  use {
    'pappasam/papercolor-theme-slim',
    config = function() require('config.papercolor-theme-slim').config() end,
  }
  use {
    'NLKNguyen/papercolor-theme',
    setup = function() require('config.papercolor-theme').setup() end,
    config = function() require('config.papercolor-theme').config() end,
  }
  use {
    'nanotech/jellybeans.vim',
    setup = function()
      vim.g.jellybeans_background_color = ''
      vim.g.jellybeans_background_color_256 = 'NONE'
    end,
  }

  -- Colorize named and hex colors.
  use {
    'norcalli/nvim-colorizer.lua',
    config = function()
      vim.opt.termguicolors = true
      require('colorizer').setup {'*', '!text'}
    end,
  }

  -- Add commands for deleting hidden and other buffers.
  use {
    'Asheq/close-buffers.vim',
    wants = {'which-key.nvim'}, -- might not be effective #615
    config = function()
      require('my').spacekeys({
        b = {
          D = {'<cmd>Bdelete hidden<cr>', 'Delete hidden buffers'},
          O = {'<cmd>Bdelete other<cr>', 'Delete other buffers'},
        },
      })
    end,
  }

  use {'tpope/vim-commentary'} -- gcc toggle comments
  use {'tpope/vim-fugitive'} -- :Gvdiffsplit
  use {'tpope/vim-rhubarb'} -- :Gbrowse for github
  use {'tpope/vim-surround'} -- dst ysiw<h1>

  -- Always change working dir to top of project.
  use {
    'airblade/vim-rooter',
    setup = function()
      vim.g.rooter_patterns = {'.git', '.project', '.hg', '.bzr', '.svn', 'package.json'}
      vim.g.rooter_silent_chdir = 1
    end,
  }

  -- Fuzzy finder.
  use {'junegunn/fzf', run = './install --bin'}
  use {
    'ibhagwan/fzf-lua',
    requires = {'kyazdani42/nvim-web-devicons'},
    wants = {'which-key.nvim'},
    config = function() require('config.fzf-lua').config() end,
  }

  -- Language server protocol.
  use {
    'neovim/nvim-lspconfig',
    requires = {
      'williamboman/nvim-lsp-installer', -- auto-install of servers
      'folke/lua-dev.nvim', -- signature help for Neovim API
      'jose-elias-alvarez/nvim-lsp-ts-utils', -- more stuff for TS
      {
        'j-hui/fidget.nvim', -- LSP progress
        config = function() require('fidget').setup {} end,
      },
      {
        'jose-elias-alvarez/null-ls.nvim',
        requires = {'nvim-lua/plenary.nvim'},
      },
    },
    wants = {'fidget.nvim', 'lua-dev.nvim', 'nvim-lsp-installer', 'nvim-lsp-ts-utils'},
    event = 'BufReadPre',
    setup = function() require('config.lsp').setup() end,
    config = function() require('config.lsp').config() end,
  }

  -- Syntax hilighting and indentation via tree-sitter.
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() vim.cmd('TSUpdate') end,
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'maintained',
        autotag = {enabled = true}, -- plugin below
        endwise = {enable = true}, -- plugin below
        highlight = {enable = true},
        indent = {enable = true},
      }
    end,
  }

  -- Auto pair completion.
  use {
    'windwp/nvim-autopairs',
    wants = {'nvim-treesitter'},
    event = 'InsertEnter',
    config = function() require('config.nvim-autopairs').config() end,
  }
  use {
    'windwp/nvim-ts-autotag',
    wants = {'nvim-treesitter'},
    event = 'InsertEnter',
  }
  use {
    'RRethy/nvim-treesitter-endwise',
    wants = {'nvim-treesitter'},
    event = 'InsertEnter',
  }

  -- editorconfig plugin with domain-specific key for setting what files should
  -- be autoformatted on save. See :help editorconfig-advanced
  use {
    'editorconfig/editorconfig-vim',
    setup = function()
      vim.g.EditorConfig_exclude_patterns = {'fugitive://.*'}
      vim.g.EditorConfig_max_line_indicator = 'none'
    end,
    config = function()
      vim.cmd([[
        function! EditorConfigAutoformatHook(config)
          if a:config['autoformat'] == 'true'
            augroup LspFormatting
              autocmd! * <buffer>
              autocmd BufWritePre <buffer> lua my.format_code()
            augroup END
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
        " The closetag.vim script is kinda broken... it requires b:unaryTagsStack
        " per buffer but only sets it once, on script load.
        autocmd BufNewFile,BufReadPre * let b:unaryTagsStack=""
        autocmd BufNewFile,BufReadPre *.html,*.md let b:unaryTagsStack="area base br dd dt hr img input link meta param"
        autocmd FileType javascriptreact,markdown,xml let b:unaryTagsStack=""

        " Replace the default closetag maps with c-/ in insert mode only.
        autocmd FileType html,javascriptreact,markdown,vue,xml inoremap <buffer> <C-/> <C-r>=GetCloseTag()<CR>
      ]])
    end,
  }

  -- CSS ---------------------------------------------------------------
  vim.cmd([[
    autocmd BufNewFile,BufReadPost *.overrides,*.variables set ft=less
  ]])

  -- Markdown ----------------------------------------------------------
  -- vim bundles vim-markdown (by tpope)
  vim.g.markdown_fenced_languages = {'html', 'python', 'bash=sh', 'clojure', 'sql'}
  vim.g.markdown_minlines = 500
  -- {'jxnblk/vim-mdx-js'}

  -- JavaScript and Vue ------------------------------------------------
  vim.cmd([[
    autocmd BufNewFile,BufReadPost *.js set filetype=javascriptreact
    autocmd FileType vue setl comments=s:<!--,m:\ \ \ \ \ ,e:-->,s1:/*,mb:*,ex:*/,://
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
        autocmd FileType clojure,lisp,scheme call MySexpMappings()
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
      my.info('Compiling plugins')
      packer.compile()
    end

    -- Packer compile when this file is written. This just re-reads, it will
    -- rebuild thanks to stale check above.
    local autocmd_patt = plugins_lua
    local abs_plugins_lua = vim.fn.resolve(plugins_lua)
    if abs_plugins_lua ~= plugins_lua then
      autocmd_patt = autocmd_patt .. ',' .. abs_plugins_lua
    end
    vim.cmd(string.format([[
        augroup reload_plugins_lua
          autocmd!
          autocmd BufWritePost %s source %s
        augroup END
      ]],
      -- Match script or abs path, because this file is in two locations via
      -- symlink/stow, and I don't want to match on generic plugins.lua
      abs_plugins_lua,
      -- What to load, don't use <afile> because that loads from both locations.
      plugins_lua
    ))
  end
end

return installed
