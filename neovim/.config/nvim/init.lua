-- init.lua
--
-- Written in 2003-2021 by Aron Griffis <aron@arongriffis.com>
-- (originally as .vimrc)
--
-- To the extent possible under law, the author(s) have dedicated all copyright
-- and related and neighboring rights to this software to the public domain
-- worldwide. This software is distributed without any warranty.
--
-- CC0 Public Domain Dedication at
-- http://creativecommons.org/publicdomain/zero/1.0/
--------------------------------------------------------------------------------

-- Aliases
local cmd = vim.api.nvim_command

-- lua 5.1 is buggy for the specific case of table with nils past the first
-- position, for example:
--
--   #{1,2,3} = 3
--   #{nil,2,3} = 3
--   #{1,nil,3} = 1 -- BUG! returns 3 in lua 5.4 and probably others
-- 
-- This bug affects unpack() which relies on the table to know its length. So we
-- replace with our own implementation that doesn't depend on the table knowing
-- its length.
local function unpork(t, n, i)
  i = i or 1
  if i <= n then
    return t[i], unpork(t, n, i + 1)
  end
end

local function test_unpork()
  local function f(...)
    return select('#', ...)
  end
  assert(f(unpack({1, nil, 3})) == 1)
  assert(f(unpork({1, nil, 3}, 3)) == 3)
  assert(f(unpork({1, nil, nil}, 3)) == 3)
end
test_unpork()

-- Given a function and arity, return a curried function.
local function curry(fn, arity)
  if not arity then
    arity = debug.getinfo(fn, 'u').nparams
  end
  return function(...)
    local nargs = select('#', ...)
    if nargs >= arity then
      return fn(...)
    end
    local args = {...}
    local fn2 = function(...) 
      -- can't do fn(unpork(), ...) because only the first element of the list
      -- returned by unpork will be used in that case. So we have to assemble
      -- the full list of args before calling unpork.
      for i = 1, select('#', ...) do
        args[nargs + i] = select(i, ...)
      end
      return fn(unpork(args, nargs + select('#', ...)))
    end
    return curry(fn2, arity - nargs)
  end
end

local function test_curry()
  local function f(z, y, x, v, w)
    return z, y, x, v, w
  end
  local a, b, c, d, e = curry(f)('a', 'b')('c')()('d', 'e')
  assert(a == 'a')
  assert(b == 'b')
  assert(c == 'c')
  assert(d == 'd')
  assert(e == 'e')
end
test_curry()

-- map(fn, tbl) Map a table through a function, returning a new table. Does not
-- modify the original table. Curried for use with compose()
local map = curry(function(fn, t)
  local r = {}
  for k, v in pairs(t) do
    r[k] = fn(v, k, t)
  end
  return r
end)

-- filter(fn, tbl) Filter a table through a function, returning a new table.
-- Does not modify the original table. Curried for use with compose()
local filter = curry(function(fn, t)
  local r = {}
  for k, v in pairs(t) do
    if fn(v, k, t) then
      r[k] = v
    end
  end
  return r
end)

local function compose(...)
  local fns = {...}
  return function(x)
    for _, fn in ipairs(fns) do
      x = fn(x)
    end
    return x
  end
end

local function merge(...)
  return vim.tbl_extend('force', ...)
end

local function keymap(mode, lhs, rhs, opts)
  local options = merge({noremap = true}, opts or {})
  options.buffer = nil
  if (opts or {}).buffer then
    vim.api.nvim_buf_set_keymap(buffer == true and 0 or buffer, mode, lhs, rhs, options)
  else
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
  end
end

local function cmap(...) keymap('c', ...) end
local function imap(...) keymap('i', ...) end
local function nmap(...) keymap('n', ...) end
local function vmap(...) keymap('v', ...) end
local function xmap(...) keymap('x', ...) end

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------
cmd('source ' .. vim.fn.stdpath('config') .. '/clipboard.vim')

vim.opt.autowrite = true      -- write before a make
vim.opt.backspace = '2'       -- allow backspacing over everything in insert mode
vim.opt.backupcopy = 'yes'    -- best for inotify
vim.opt.cscopetag = true      -- search cscope on ctrl-] and :tag
vim.opt.hidden = true         -- enable background buffers
vim.opt.history = 100         -- keep 100 lines of command line history
vim.opt.inccommand = 'nosplit' -- show substitute while typing
vim.opt.joinspaces = false    -- two spaces after a period is for old fogeys
vim.opt.laststatus = 2        -- always show a status line (with the current filename)
vim.opt.listchars = {tab = '»·', trail = '·'}
vim.opt.modeline = true
vim.opt.modelines = 5
vim.opt.paragraphs = ''       -- otherwise NROFF macros screw up CSS
vim.opt.pastetoggle = '<F10>'
vim.opt.report = 0            -- threshold for reporting nr. of lines changed
vim.opt.ruler = true          -- show the cursor position all the time
vim.opt.shada = "!,'10,f0,h,s100" -- keep fast by avoiding lots of file/dir stats
vim.opt.showcmd = true        -- show (partial) command in status line
vim.opt.showmode = true       -- message on status line to show current mode
vim.opt.showmatch = true      -- briefly jump to matching bracket
vim.opt.warn = false          -- don't warn for shell command when buffer changed
vim.opt.updatetime = 2000
vim.opt.wildmode = {'longest', 'list', 'full'}
vim.opt.wrap = false

-- Settings: tabs and indents
vim.opt.autoindent = true
vim.opt.comments = 'b:#,b:##,n:>,fb:-,fb:*'
vim.opt.expandtab = true    -- default unless overridden by autocmd
-- formatoptions are in the order presented in fo-table
-- a and w are left out because we set them in muttrc for format=flowed
vim.opt.formatoptions:append {'t'} -- auto-wrap using textwidth (not comments)
vim.opt.formatoptions:append {'c'} -- auto-wrap comments too
vim.opt.formatoptions:append {'r'} -- continue the comment header automatically on <CR>
vim.opt.formatoptions:remove {'o'} -- don't insert comment leader with 'o' or 'O'
vim.opt.formatoptions:append {'q'} -- allow formatting of comments with gq
-- set formatoptions-=w   " double-carriage-return indicates paragraph
-- set formatoptions-=a   " don't reformat automatically
vim.opt.formatoptions:append {'n'} -- recognize numbered lists when autoindenting
vim.opt.formatoptions:append {'2'} -- use second line of paragraph when autoindenting
vim.opt.formatoptions:remove {'v'} -- don't worry about vi compatiblity
vim.opt.formatoptions:remove {'b'} -- don't worry about vi compatiblity
vim.opt.formatoptions:append {'l'} -- don't break long lines in insert mode
vim.opt.formatoptions:append {'1'} -- don't break lines after one-letter words, if possible
vim.opt.shiftround = true -- round indent < and > to multiple of shiftwidth
vim.opt.shiftwidth = 2    -- overridden by editorconfig etc.
vim.opt.smarttab = true   -- use shiftwidth when inserting <Tab>
vim.opt.tabstop = 8       -- number of spaces that <Tab> in file uses
vim.opt.textwidth = 80    -- by default, although plugins or autocmds can modify

-- Settings: search and completion
vim.opt.complete:remove {'t'} -- don't search tags files by default
vim.opt.complete:remove {'i'} -- don't search included files -- takes too long
vim.opt.ignorecase = true -- "foo" matches "Foo", etc
vim.opt.infercase = true  -- adjust the case of the match with ctrl-p/ctrl-n
vim.opt.smartcase = true  -- ignorecase only when the pattern is all lower
vim.opt.hlsearch = false  -- by default, don't highlight matches after they're found
vim.opt.grepprg = 'rg --hidden --line-number --smart-case --sort-files'

-- Settings: windowing
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.equalalways = true   -- keep windows equal when splitting (default)
vim.opt.eadirection = 'both' -- ver/hor/both - where does equalalways apply
vim.opt.fillchars = 'vert:╎'
vim.opt.winwidth = 40

-- Settings: terminal
vim.opt.termguicolors = true

-- Enable bracketed paste everywhere. This would happen automatically on
-- local terms, even with mosh using TERM=xterm*, but doesn't happen
-- automatically in tmux with TERM=screen*. Setting it manually works fine.
if vim.fn.has('gui_running') == 0 and vim.go.t_BE == '' then
  vim.go.t_BE = '\27[?2004h' -- enable
  vim.go.t_BD = '\27[?2004l' -- disable
  vim.go.t_PS = '\27[200~'   -- start
  vim.go.t_PE = '\27[201~'   -- end
end

-- Set the map leaders to SPC and SPC-m similar to Spacemacs.
-- These must be set before referring to <leader> in maps
vim.g.mapleader = ' '
vim.g.maplocalleader = ' m'

--------------------------------------------------------------------------------
-- Packages to load with paq, with custom pre/post entries
--------------------------------------------------------------------------------
packages = {
  -- let paq manage itself
  {'savq/paq-nvim'},

  ----------------------------------------------------------------------
  -- main interface: airline, bufferline, spacevim, colors
  ----------------------------------------------------------------------
  {
    'vim-airline/vim-airline',
    pre = function()
      vim.g.airline_left_sep = ''
      vim.g.airline_left_alt_sep = ''
      vim.g.airline_right_sep = ''
      vim.g.airline_right_alt_sep = ''
      vim.g.airline_symbols = {
        branch = '',
        keymap = 'Keymap:',
        linenr = '¶',
        modified = '+',
        paste = 'PASTE',
        readonly = '',
        space = ' ',
        spell = 'SPELL',
        whitespace = '',
      }
      -- https://github.com/vim-airline/vim-airline#smarter-tab-line
      vim.g['airline#extensions#tabline#enabled'] = 1
      vim.g['airline#extensions#tabline#formatter'] = 'short_path'
      vim.g['airline#extensions#tabline#left_sep'] = ''
      vim.g['airline#extensions#tabline#left_alt_sep'] = ''
      vim.g['airline#extensions#tabline#right_sep'] = ''
      vim.g['airline#extensions#tabline#right_alt_sep'] = ''
    end,
  },
  {'vim-airline/vim-airline-themes'},

  {
    'ctjhoa/spacevim',
    pre = function()
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
  },

  {
    'NLKNguyen/papercolor-theme',
    pre = function()
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
    end,
  },
  {
    'nanotech/jellybeans.vim',
    pre = function()
      vim.g.jellybeans_background_color = ''
      vim.g.jellybeans_background_color_256 = 'NONE'
    end,
  },

  {
    'norcalli/nvim-colorizer.lua',
    post = function()
      require('colorizer').setup {'*', '!text'}
    end,
  },

  ----------------------------------------------------------------------
  -- global utilities
  ----------------------------------------------------------------------
  {'tpope/vim-commentary'}, -- gcc toggle comments
  {'tpope/vim-fugitive'}, -- :Gvdiffsplit
  {'tpope/vim-surround'}, -- dst ysiw<h1>

  {
    'junegunn/vim-easy-align',
    post = function()
      xmap('ga', '<Plug>(EasyAlign)')
    end,
  },

  ----------------------------------------------------------------------
  -- projects
  ----------------------------------------------------------------------
  {
    'airblade/vim-rooter',
    pre = function()
      vim.g.rooter_patterns = {'.git', '.project', '.hg', '.bzr', '.svn', 'package.json'}
      vim.g.rooter_silent_chdir = 1
    end,
  },

  {
    'junegunn/fzf',
    run = function() vim.fn['fzf#install']() end,
    pre = function()
      function build_fzf_quickfix_list(lines)
        vim.fn.setqflist(vim.fn.map(vim.fn.copy(lines), '{ "filename": v:val }'))
        cmd([[copen | cc]])
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

      cmd([[
        command! -bang ProjectFiles call fzf#vim#files(getcwd(), fzf#vim#with_preview(), <bang>0)
      ]])

      cmd([[
        command! -bang -nargs=* ProjectRg call v:lua.fzfProjectRg(<q-args>, <bang>0)
      ]])

      nmap('<leader>ff', ':FZF <C-R>=expand("%:p:h")<CR><CR>')
      nmap('<leader>fh', ':History<CR>')
      nmap('<leader>pf', ':ProjectFiles<CR>')
      nmap('<c-p>',      ':ProjectFiles<CR>')
      nmap('<leader>fg', ':GFiles?<CR>')
      nmap('<leader>sP', ':ProjectRg <C-R>=expand("<cword>")<CR><CR>')
      nmap('<leader>*',  ':ProjectRg <C-R>=expand("<cword>")<CR><CR>')
      nmap('<leader>sp', ':ProjectRg<CR>')
      nmap('<leader>/',  ':ProjectRg<CR>')
      nmap('<leader>bb', ':Buffers<CR>')
    end,
  },
  {'junegunn/fzf.vim'},

  ----------------------------------------------------------------------
  -- programming: lsp, tree-sitter, formatting
  ----------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',

    pre = function()
      vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
    end,

    post = function()
      local lspconfig = require('lspconfig')

      local function on_attach(client, bufnr)
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
          nmap(lhs, '<cmd>lua vim.lsp.buf.' .. rhs .. '()<CR>', {buffer = bufnr, silent = true})
        end
        setlocal('omnifunc', 'v:lua.vim.lsp.omnifunc')
        vim.opt.completeopt:remove {'preview'} -- completeopt is global, not buffer-local
      end

      for _, entry in ipairs({
        {lsp = 'cssls', exe = 'css-languageserver'},
        {lsp = 'jdtls', exe = 'jdtls', opts = {cmd = {'jdtls'}}},
        {lsp = 'tsserver', exe = 'typescript-language-server'},
        {lsp = 'vuels', exe = 'vls'},
      }) do
        if vim.fn.executable(entry.exe) == 1 then
          lspconfig[entry.lsp].setup(merge({on_attach = on_attach}, entry.opts or {}))
        end
      end
    end,
  },

  -- syntax hilighting via tree-sitter
  {
    'nvim-treesitter/nvim-treesitter',

    run = function()
      cmd('TSUpdate')
    end,

    post = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'maintained',
        highlight = {enable = true},
        indent = {enable = true},
      }
    end,
  },

  -- code formatting
  {'google/vim-maktaba'},
  {
    'google/vim-glaive',
    post = function()
      cmd('call glaive#Install()')
    end,
  },
  {
    'agriffis/vim-codefmt',
    branch = 'scampersand',
    post = function()
      cmd('Glaive codefmt plugin[mappings]')
    end,
  },

  -- This is the official editorconfig plugin. There is also an alternative
  -- sgur/vim-editorconfig which used to be preferable because it was pure VimL
  -- whereas the official plugin required Python. Now the official plugin
  -- doesn't require Python, and it provides an API for fetching domain-specific
  -- keys, see :help editorconfig-advanced
  {
    'editorconfig/editorconfig-vim',
    pre = function()
      vim.g.EditorConfig_exclude_patterns = {'fugitive://.*'}
      vim.g.EditorConfig_max_line_indicator = 'none'
    end,
    post = function()
      local function editorConfigAutoformatHook(config)
        if config.autoformat and vim.fn.exists(':AutoFormatBuffer') == 1 then
          -- configure google/codefmt to format automatically on save
          cmd('AutoFormatBuffer ' .. config.autoformat)
        end
        return 0 -- success
      end
      vim.fn['editorconfig#AddNewHook'](editorConfigAutoformatHook)
    end,
  },

  ----------------------------------------------------------------------
  -- Languages
  ----------------------------------------------------------------------

  -- HTML --------------------------------------------------------------
  {
    pre = function()
      -- Assume <p> will include closing </p> and content should be indented.
      -- If more are needed, this should be a comma-separated list.
      vim.g.html_indent_inctags = 'p,main'
    end,
  },
  -- {'agriffis/vim-jinja'},
  -- {'mustache/vim-mustache-handlebars'},
  {
    'agriffis/closetag.vim',
    post = function()
      -- The closetag.vim script is kinda broken... it requires b:unaryTagsStack
      -- per buffer but only sets it once, on script load.
      cmd([[autocmd BufNewFile,BufReadPre * let b:unaryTagsStack="area base br dd dt hr img input link meta param"]])
      cmd([[autocmd FileType javascriptreact,markdown,xml let b:unaryTagsStack=""]])
      -- Replace the default closetag maps with c-/ in insert mode only.
      cmd([[autocmd FileType html,javascriptreact,markdown,vue,xml inoremap <buffer> <C-/> <C-r>=GetCloseTag()<CR>]])
    end,
  },

  -- CSS ---------------------------------------------------------------
  {
    post = function()
      cmd([[autocmd BufNewFile,BufReadPost *.overrides,*.variables set ft=less]])
    end,
  },

  -- Markdown ----------------------------------------------------------
  {
    -- vim bundles vim-markdown (by tpope)
    pre = function()
      vim.g.markdown_fenced_languages = {'html', 'python', 'bash=sh', 'clojure', 'sql'}
      vim.g.markdown_minlines = 500
    end,
  },
  -- {'jxnblk/vim-mdx-js'},

  -- JavaScript --------------------------------------------------------
  {
    pre = function()
      cmd('autocmd BufNewFile,BufReadPost *.js set filetype=javascriptreact')
    end,
  },
}

------------------------------------------------------------------------
-- Bootstrap paq
------------------------------------------------------------------------
local install_path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if vim.fn.isdirectory(install_path) == 0 then
  vim.fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end

------------------------------------------------------------------------
-- Load packages, with pre/post phases
------------------------------------------------------------------------
for i, p in ipairs(packages) do
  if p.pre then p.pre() end

  if p.filetypes ~= nil then
    p.opt = true
    local function auto(s)
      cmd('autocmd FileType ' .. table.concat(p.filetypes, ',') .. ' ' .. s)
    end
    auto('packadd ' .. (p.as or vim.fn.split(p[1], '/')[2]))
    if p.once then
      p._run_once = function()
        if not p._ran_once then
          p._ran_once = true
          p.once()
        end
      end
      auto('lua packages[' .. i .. ']._run_once()')
    end
    if p.each then
      auto('lua packages[' .. i .. '].each()')
    end
  end
end

require('paq')(compose(
  -- Drop our special keys before passing to paq
  map(filter(function(_, k)
    return k ~= 'pre' and k ~= 'post' and k ~= 'filetypes' and k ~= 'each' and k ~= 'once'
  end)),
  -- Skip packages consisting only of pre/post
  filter(function(p)
    return type(p[1]) == 'string' or p.as ~= nil or p.url ~= nil
  end)
)(packages))

cmd('packloadall')

-- TODO don't run post unless package loaded (check runtimepath?)
for i, p in ipairs(packages) do if p.post then p.post() end end

------------------------------------------------------------------------
-- Theming
------------------------------------------------------------------------
cmd('source ' .. vim.fn.stdpath('config') .. '/themer.vim')

------------------------------------------------------------------------
-- Mappings
------------------------------------------------------------------------
-- Global replace
nmap('<leader>sr', ':%s/\\<<C-R>=expand("<cword>")<cr>\\>//g<left><left>')

-- Insert path of current file on command-line with %/
cmap('%/', '<C-R>=expand("%:p:h")."/"<CR>')

-- Reformat current paragraph
nmap('Q', '}{gq}')
vmap('Q', 'gq')

------------------------------------------------------------------------
-- Final
------------------------------------------------------------------------
-- When editing a file, always jump to the last cursor position.
-- This duplicates an autocmd provided by fedora, so clear that.
cmd([[
augroup user
  augroup fedora!
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  autocmd BufReadPost COMMIT_EDITMSG exe "normal! gg"
augroup END
]])

-- Load plugins now to prevent conflict with those that modify &bin
cmd('runtime! plugin/*.vim')

if vim.fn.filereadable(vim.fn.expand('~/.vimrc.mine')) == 1 then
  cmd('source ~/.vimrc.mine')
end
