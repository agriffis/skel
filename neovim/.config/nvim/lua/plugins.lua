------------------------------------------------------------------------
-- Bootstrap packer.nvim
------------------------------------------------------------------------
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.isdirectory(install_path) == 0 then
  vim.fn.system({'git', 'clone', '--depth=1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

------------------------------------------------------------------------
-- Auto-regenerate compiled loader file
------------------------------------------------------------------------
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

--------------------------------------------------------------------------------
-- Load packages with packer.nvim
--------------------------------------------------------------------------------
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  ----------------------------------------------------------------------
  -- main interface: spacevim bindings, airline, colors
  ----------------------------------------------------------------------
  use {
    'ctjhoa/spacevim',
    setup = function()
      vim.g.spacevim_enabled_layers = {
        'core/buffers',
        'core/buffers/move',
        'core/quit',
        'core/root',
        'core/toggles',
        'core/toggles/colors',
        'core/toggles/highlight',
        'core/windows',
        'syntax-checking',
      }
    end,
  }

  use {
    'vim-airline/vim-airline',
    setup = function()
      vim.g.airline_powerline_fonts = 1
      vim.g.airline_left_sep = ''
      vim.g.airline_left_alt_sep = ''
      vim.g.airline_right_sep = ''
      vim.g.airline_right_alt_sep = ''
      -- https://github.com/vim-airline/vim-airline#smarter-tab-line
      vim.g['airline#extensions#tabline#enabled'] = 1
      vim.g['airline#extensions#tabline#formatter'] = 'short_path'
      vim.g['airline#extensions#tabline#left_sep'] = ''
      vim.g['airline#extensions#tabline#left_alt_sep'] = ''
      vim.g['airline#extensions#tabline#right_sep'] = ' '
      vim.g['airline#extensions#tabline#right_alt_sep'] = ' '
      --
      vim.g['airline#extensions#tabline#buffer_idx_mode'] = 1
      vim.cmd([[
        nmap <leader>1 <Plug>AirlineSelectTab1
        nmap <leader>2 <Plug>AirlineSelectTab2
        nmap <leader>3 <Plug>AirlineSelectTab3
        nmap <leader>4 <Plug>AirlineSelectTab4
        nmap <leader>5 <Plug>AirlineSelectTab5
        nmap <leader>6 <Plug>AirlineSelectTab6
        nmap <leader>7 <Plug>AirlineSelectTab7
        nmap <leader>8 <Plug>AirlineSelectTab8
        nmap <leader>9 <Plug>AirlineSelectTab9
        nmap <leader>0 <Plug>AirlineSelectTab0
      ]])
    end,
    config = function() 
      vim.g.airline_symbols = my.merge(vim.g.airline_symbols, {
        branch = '',
        keymap = 'Keymap:',
        readonly = '',
        space = ' ',
        spell = 'SPELL',
        whitespace = '',
      })
    end,
  }
  use {'vim-airline/vim-airline-themes'}

  -- provides :Bdelete other and :Bdelete hidden
  use {
    'Asheq/close-buffers.vim',
    config = function()
      my.nmap('<leader>bD', ':Bdelete hidden<cr>')
    end,
  }

  -- setup function doesn't seem to work for color schemes, so inline here.
  vim.g.PaperColor_Theme_Options = {
    theme = {
      default = {
        transparent_background = 1,
        allow_bold = 1,
        allow_italic = 1,
      },
      ['default.light'] = {
        override = {
          color07 = {'#000000', '16'},
        }
      }
    }
  }
  use {'NLKNguyen/papercolor-theme'}
  vim.g.jellybeans_background_color = ''
  vim.g.jellybeans_background_color_256 = 'NONE'
  use {'nanotech/jellybeans.vim'}

  use {
    'norcalli/nvim-colorizer.lua',
    config = function()
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

  use {
    'junegunn/vim-easy-align',
    config = function()
      my.xmap('ga', '<Plug>(EasyAlign)')
    end,
  }

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

  use {
    'junegunn/fzf',
    run = './install --bin',

    setup = function()
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

      my.nmap('<leader>ff', ':FZF <C-R>=expand("%:p:h")<CR><CR>')
      my.nmap('<leader>fh', ':History<CR>')
      my.nmap('<leader>pf', ':ProjectFiles<CR>')
      my.nmap('<c-p>',      ':ProjectFiles<CR>')
      my.nmap('<leader>fg', ':GFiles?<CR>')
      my.nmap('<leader>sP', ':ProjectRg <C-R>=expand("<cword>")<CR><CR>')
      my.nmap('<leader>*',  ':ProjectRg <C-R>=expand("<cword>")<CR><CR>')
      my.nmap('<leader>sp', ':ProjectRg<CR>')
      my.nmap('<leader>/',  ':ProjectRg<CR>')
      my.nmap('<leader>bb', ':Buffers<CR>')
    end,
  }
  use {'junegunn/fzf.vim'}

  ----------------------------------------------------------------------
  -- programming: lsp, tree-sitter, formatting
  ----------------------------------------------------------------------
  use {
    'neovim/nvim-lspconfig',

    setup = function()
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
         vim.lsp.diagnostic.on_publish_diagnostics, {
           signs = false,
           underline = true,
           virtual_text = false,
         }
      )
      vim.cmd([[
        " Underlining doesn't look good in tmux, which changes the curly
        " underlines to plain. Instead rely on PaperColor to set the
        " background colors.
        autocmd ColorScheme PaperColor hi! SpellBad cterm=NONE gui=NONE
        autocmd ColorScheme PaperColor hi! SpellCap cterm=NONE gui=NONE
        autocmd ColorScheme PaperColor hi! SpellRare cterm=NONE gui=NONE
        autocmd ColorScheme * hi! link LspDiagnosticsUnderlineError SpellBad
        autocmd ColorScheme * hi! link LspDiagnosticsUnderlineWarning SpellCap
        autocmd ColorScheme * hi! link LspDiagnosticsUnderlineHint SpellRare
        autocmd ColorScheme * hi! link LspDiagnosticsUnderlineInformation SpellRare
      ]])
    end,

    config = function()
      local lspconfig = require('lspconfig')

      -- reused for jdtls below
      my.on_lsp_attach = function(client, bufnr)
        local function setlocal(...) vim.api.nvim_buf_set_option(bufnr, ...) end
        for lhs, rhs in pairs({
          gA = 'code_action',
          gD = 'declaration',
          gd = 'definition',
          K = 'hover',
          gi = 'implementation',
          ['<c-k>'] = 'signature_help',
          gt = 'type_definition',
          gr = 'references',
          gR = 'rename',
          g0 = 'document_symbol',
          gW = 'workspace_symbol',
        }) do
          my.nmap(lhs, '<cmd>lua vim.lsp.buf.' .. rhs .. '()<CR>', {buffer = bufnr, silent = true})
        end
        my.nmap('ge', '<cmd>lua vim.lsp.diagnostic.show_position_diagnostics()<cr>')
        my.nmap('[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>')
        my.nmap(']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>')
        my.nmap('<leader>e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>')
        my.nmap('<leader>E', '<cmd>lua vim.lsp.diagnostic.set_qflist()<cr>')
        setlocal('omnifunc', 'v:lua.vim.lsp.omnifunc')
        vim.opt.completeopt:remove {'preview'} -- completeopt is global, not buffer-local
      end

      for _, entry in ipairs({
        {lsp = 'cssls', exe = 'css-languageserver'},
        {lsp = 'jdtls'},
        {lsp = 'tsserver', exe = 'typescript-language-server'},
        {lsp = 'vuels', exe = 'vls'},
      }) do
        if entry.exe == nil or vim.fn.executable(entry.exe) == 1 then
          lspconfig[entry.lsp].setup(my.merge({on_attach = my.on_lsp_attach}, entry.opts or {}))
        end
      end
    end,
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

  -- code formatting
  use {'google/vim-maktaba'}
  use {
    'google/vim-glaive',
    config = function()
      vim.fn['glaive#Install']()
    end,
    requires = {'google/vim-maktaba'},
  }
  use {
    'agriffis/vim-codefmt',
    branch = 'scampersand',
    requires = {'google/vim-glaive'},

    config = function()
      vim.cmd([[
        Glaive codefmt plugin[mappings]
      ]])

      -- Extra setup for prettier
      --
      -- Don't do this unilaterally:
      --   Glaive codefmt prettier_executable=`['yarn', 'prettier']`
      -- because it's 6x slower (1.2s vs 0.2s) than the default
      -- npx in vim-codefmt upstream. Unfortunately npx doesn't work with yarn
      -- v2 pnp, but it does work fine with yarn in general.
      if vim.fn.executable('proxier') == 1 then
        vim.cmd([[
          Glaive codefmt prettier_executable=`['proxier']`
        ]])
      end

      -- Extra setup for zprint
      --
      -- Default formatting keys <leader>== and <leader>=b respect existing
      -- newlines for minimal disruption. Extra formatting keys <leader>=+ and
      -- <leader>++ and <leader>=B respect blank lines only.
      vim.cmd([[
        Glaive codefmt zprint_options=`[]`
        function! RespectableZprint(respect, what) abort
          if a:respect == 'nl'
            Glaive codefmt zprint_options=`['{:style [:respect-nl]}']`
          else
            Glaive codefmt zprint_options=`['{:style [:respect-bl]}']`
          endif
          try
            if a:what == 'buffer'
              FormatCode zprint
            else
              exe "normal vaF:FormatLines zprint\<cr>"
            endif
          finally
            Glaive codefmt zprint_options=`[]`
          endtry
        endfunction
        autocmd FileType clojure nmap <buffer> <silent> <leader>== :call RespectableZprint('nl', 'fn')<cr>
        autocmd FileType clojure nmap <buffer> <silent> <leader>=+ :call RespectableZprint('bl', 'fn')<cr>
        autocmd FileType clojure nmap <buffer> <silent> <leader>++ :call RespectableZprint('bl', 'fn')<cr>
        autocmd FileType clojure nmap <buffer> <silent> <leader>=b :call RespectableZprint('nl', 'buffer')<cr>
        autocmd FileType clojure nmap <buffer> <silent> <leader>=B :call RespectableZprint('bl', 'buffer')<cr>
      ]])
    end,
  }

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
  use {'eraserhd/parinfer-rust', run = 'cargo build --release'}
  use {'Olical/conjure'}
end)
