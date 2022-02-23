-- init.lua
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

local compose = my.compose
local filter = my.filter
local map = my.map
local merge = my.merge

-- Default global settings
require('settings')

-- -- Plugins loaded via Packer
-- require('plugins')
-- 
-- -- Continuously sync theme with desktop/terminal scheme (dark/light)
-- my.source('themer.vim')



--------------------------------------------------------------------------------
-- Packages
--------------------------------------------------------------------------------
vim.cmd([[
  augroup user
    autocmd!
  augroup END
]])

-- These will be loaded with paq, with custom setup/config entries.
local packages = {
  -- Let paq keep itself updated.
  {'savq/paq-nvim'},

  -- Icons used by other plugins.
  {'kyazdani42/nvim-web-devicons'},

  -- Key binding manager with popup for discovery. We add a bunch of
  -- Spacemacs-inspired bindings below.
  {
    'folke/which-key.nvim',
    config = function() require('which-key').setup() end
  },

  -- Status line. Consider replacing with LuaLine eventually.
  {
    'vim-airline/vim-airline',
    config = function() require('config.vim-airline').config() end,
  },
  {
    'vim-airline/vim-airline-themes',
    config = function() require('config.vim-airline-themes').config() end,
  },

  -- File explorer.
  {
    'kyazdani42/nvim-tree.lua',
    config = function()
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        update_focused_file = {
          enable = true,
        },
      })
    end,
  },

  -- Add commands for deleting hidden and other buffers.
  {'Asheq/close-buffers.vim'},

  -- Color schemes.
  {
    'pappasam/papercolor-theme-slim',
    setup = function()
      vim.cmd([[
        augroup user
          " https://github.com/pappasam/papercolor-theme-slim#transparent-background
          autocmd ColorScheme PaperColorSlim hi Normal guibg=none

          " Underlining doesn't look good in tmux, which changes the curly
          " underlines to plain. Instead rely on PaperColor to set the
          " background colors.
          autocmd ColorScheme PaperColorSlim hi SpellBad cterm=NONE gui=NONE
          autocmd ColorScheme PaperColorSlim hi SpellCap cterm=NONE gui=NONE
          autocmd ColorScheme PaperColorSlim hi SpellRare cterm=NONE gui=NONE
          autocmd ColorScheme PaperColorSlim hi link LspDiagnosticsUnderlineError SpellBad
          autocmd ColorScheme PaperColorSlim hi link LspDiagnosticsUnderlineWarning SpellCap
          autocmd ColorScheme PaperColorSlim hi link LspDiagnosticsUnderlineHint SpellRare
          autocmd ColorScheme PaperColorSlim hi link LspDiagnosticsUnderlineInformation SpellRare

          " Airline doesn't know about PaperColorSlim.
          autocmd ColorScheme PaperColorSlim let g:airline_theme = 'papercolor'
        augroup END

        " In case the theme is already set?
        if exists('g:colors_name') && g:colors_name == 'PaperColorSlim'
          let g:airline_theme = 'papercolor'
        endif
      ]])
    end,
  },
  {
    'NLKNguyen/papercolor-theme',
    setup = function()
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
            },
          },
        },
      }
    end
  },
  {
    'nanotech/jellybeans.vim',
    setup = function()
      vim.g.jellybeans_background_color = ''
      vim.g.jellybeans_background_color_256 = 'NONE'
    end,
  },

  -- Colorize named and hex colors.
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      vim.opt.termguicolors = true -- required
      require('colorizer').setup {'*', '!text'}
    end,
  },

  {'tpope/vim-commentary'}, -- gcc toggle comments
  {'tpope/vim-fugitive'}, -- :Gvdiffsplit
  {'tpope/vim-rhubarb'}, -- :Gbrowse for github
  {'tpope/vim-surround'}, -- dst ysiw<h1>

  -- Change working directory to project root.
  {
    'airblade/vim-rooter',
    config = function()
      vim.g.rooter_patterns = {'.git', '.project', '.hg', '.bzr', '.svn', 'package.json'}
      vim.g.rooter_silent_chdir = 1
    end,
  },

  -- Fuzzy finder.
  {'junegunn/fzf', run = './install --bin'},
  {
    'ibhagwan/fzf-lua',
    config = function()
      require('fzf-lua').setup({
        -- winopts = {preview = {default = 'bat'}},
      })
      require('which-key').register({
        ['<c-p>'] = {'<cmd>FzfLua files<cr>', 'Open file in project'},
      })
    end,
  },

  -- Language Server Protocol
  {
    'neovim/nvim-lspconfig',
    setup = function()
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
          signs = false,
          underline = true,
          virtual_text = false,
        }
      )
    end,
    config = function() require('config.lsp').config() end,
  },

  -- Syntax highlighting and indentation via treesitter.
  {
    'nvim-treesitter/nvim-treesitter',
    run = function() vim.cmd('TSUpdate') end,
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'maintained',
        highlight = {enable = true},
        indent = {enable = true},
      }
    end,
  },

--  -- code formatting
--  {'google/vim-maktaba'},
--  {
--    'google/vim-glaive',
--    config = function()
--      vim.fn['glaive#Install']()
--    end,
--    requires = {'google/vim-maktaba'},
--  },
--  {
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
--  },

  -- This is the official editorconfig plugin. There is also an alternative
  -- sgur/vim-editorconfig which used to be preferable because it was pure VimL
  -- whereas the official plugin required Python. Now the official plugin
  -- doesn't require Python, and it provides an API for fetching domain-specific
  -- keys, see :help editorconfig-advanced
  {
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
  },

  ----------------------------------------------------------------------
  -- Languages
  ----------------------------------------------------------------------

  -- HTML --------------------------------------------------------------
  -- Assume <p> will include closing </p> and content should be indented.
  -- If more are needed, this should be a comma-separated list.
  {
    setup = function()
      vim.g.html_indent_inctags = 'p,main'
    end
  },

  -- {'agriffis/vim-jinja'}
  -- {'mustache/vim-mustache-handlebars'}
  -- {'windwp/nvim-ts-autotag'}
  {
    'agriffis/closetag.vim',
    config = function()
      vim.cmd([[
        augroup user
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
  },

  -- CSS ---------------------------------------------------------------
  {
    setup = function()
      vim.cmd([[
        augroup user
          autocmd BufNewFile,BufReadPost *.overrides,*.variables set ft=less
        augroup END
      ]])
    end,
  },

  -- Markdown ----------------------------------------------------------
  -- vim bundles vim-markdown (by tpope)
  {
    setup = function()
      vim.g.markdown_fenced_languages = {'html', 'python', 'bash=sh', 'clojure', 'sql'}
      vim.g.markdown_minlines = 500
    end,
  },
  -- {'jxnblk/vim-mdx-js'}

  -- JavaScript and Vue ------------------------------------------------
  {
    config = function()
      vim.cmd([[
        augroup user
          autocmd BufNewFile,BufReadPost *.js set filetype=javascriptreact
          autocmd FileType vue setl comments=s:<!--,m:\ \ \ \ \ ,e:-->,s1:/*,mb:*,ex:*/,://
        augroup END
      ]])
    end,
  },

  -- Java and Clojure --------------------------------------------------
  {'tpope/vim-classpath'},
  {'Olical/conjure'},
  {
    'guns/vim-sexp',
    setup = function()
      vim.g.sexp_insert_after_wrap = 0
    end,
  },
  {
    'tpope/vim-sexp-mappings-for-regular-people',
    config = function()
      vim.cmd([[
        function! MySexpMappings() abort
          nmap <buffer> ><  <Plug>(sexp_emit_head_element)
          nmap <buffer> <>  <Plug>(sexp_emit_tail_element)
          nmap <buffer> <<  <Plug>(sexp_capture_prev_element)
          nmap <buffer> >>  <Plug>(sexp_capture_next_element)
        endfunction
        augroup user
          autocmd FileType clojure,lisp,scheme call MySexpMappings()
        augroup END
      ]])
    end,
  },
}

------------------------------------------------------------------------
-- Paq
------------------------------------------------------------------------
local paqs_path = vim.fn.stdpath('data') .. '/site/pack/paqs'
local paq_install_path = paqs_path .. '/start/paq-nvim'
local paq_installed = vim.fn.isdirectory(paq_install_path) == 1
local paq_bootstrapped = false

local function infer_name(p)
  -- This is the precedence used in paq
  return (
    p.as or
    (p.url and p.url:gsub('.*/', ''):gsub('%.git$', '')) or
    (p[1] and p[1]:gsub('.*/', ''))
  )
end

local function infer_url(p)
  return (
    p.url or
    (p[1] and 'https://github.com/' .. p[1])
  )
end

local function is_installed(p)
  local name = type(p) == 'string' and p or infer_name(p)
  if name then
    for _, path in ipairs({
      paqs_path .. '/start/' .. name,
      paqs_path .. '/opt/' .. name,
    }) do
      if vim.fn.isdirectory(path) == 1 then
        return path
      end
    end
  end
end

if not paq_installed then
  vim.fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', paq_install_path})
  paq_bootstrapped = vim.v.shell_error == 0
  if paq_bootstrapped then
    vim.cmd('packadd paq-nvim')
    paq_installed = true
  end
end

if paq_installed then
  for i, p in ipairs(packages) do
    if is_installed(p) and p.setup and not pcall(p.setup) then
      print('setup failed for ' .. (p.label or p[1] or 'unknown'))
    end
  end

  require('paq')(compose(
    -- Skip packages that don't have a name
    filter(infer_name),
    -- Drop our special keys before passing to paq
    map(filter(function(_, k)
      return k ~= 'setup' and k ~= 'config'
    end))
  )(packages))

  vim.cmd('packloadall')

  for i, p in ipairs(packages) do
    if is_installed(p) and p.config and not pcall(p.config) then
      print('config failed for ' .. (p.label or p[1] or 'unknown'))
    end
  end

  for i, p in ipairs(packages) do
    if infer_name(p) and not is_installed(p) then
      print('Please run :PaqSync (' .. infer_name(p) .. ')')
      break
    end
  end
end

------------------------------------------------------------------------
-- Theme
------------------------------------------------------------------------
-- Continuously sync theme with desktop/terminal scheme (dark/light)
my.source('themer.vim')

------------------------------------------------------------------------
-- Mappings
------------------------------------------------------------------------
my.spacekeys({
  b = {
    name = 'Buffer operations',
    -- Provided by fzf-lua
    b = {'<cmd>FzfLua buffers<cr>', 'Choose from open buffers'},
    --
    d = {'<cmd>bd<cr>', 'Delete current buffer'},
    -- Provided by close-buffers.vim
    D = {'<cmd>Bdelete hidden<cr>', 'Delete hidden buffers'},
    O = {'<cmd>Bdelete other<cr>', 'Delete other buffers'},
    -- Provided by vim-airline
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
    --
    ['<tab>'] = {'<cmd>b#<cr>', 'Switch to previous buffer'},
  },
  f = {
    name = 'File operations',
    f = {'<cmd>FzfLua files cwd=<c-r>=expand("%:p:h")<cr><cr>', 'Open file in current dir'},
    h = {'<cmd>FzfLua oldfiles<cr>', 'Open recent file'},
  },
  g = {
    name = 'Code operations',
  },
  p = {
    name = 'Project operations',
    f = {'<cmd>FzfLua files<cr>', 'Open file in project'},
  },
  s = {
    name = 'Search operations',
    p = {'<cmd>FzfLua live_grep<cr>', 'Search project'},
    P = {
      function()
        require('fzf-lua').live_grep({
          search = vim.fn.expand('<cword>'),
        })
      end,
      'Search project for current word',
    },
    l = {'<cmd>FzfLua resume<cr>', 'Resume last search'},
  },
  t = {
    name = 'Toggles',
    f = {'<cmd>NvimTreeToggle<cr>', 'Toggle file explorer'},
  },
  ['/'] = {'<cmd>FzfLua live_grep<cr>', 'Search project'},
  ['*'] = {
    function()
      require('fzf-lua').live_grep({
        search = vim.fn.expand('<cword>'),
      })
    end,
    'Search project for current word',
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





-- Up/down through wrapped lines.
my.nmap('k', 'v:count == 0 ? "gk" : "k"', {expr = true})
my.nmap('j', 'v:count == 0 ? "gj" : "j"', {expr = true})

-- Paste over currently selected without yanking.
my.vmap('p', '"_dP')

-- Move selected line/block in visual mode.
my.xmap('K', ":move '<-2<cr>gv-gv")
my.xmap('J', ":move '<+1<cr>gv-gv")

-- Resize pane with arrows in normal mode.
-- For rightmost/bottommost pane, swap bindings so it feels right.
my.nmap('<right>', 'winnr() == winnr("l") ? ":vertical resize -1<cr>" : ":vertical resize +1<cr>"', {expr = true})
my.nmap('<left>',  'winnr() == winnr("l") ? ":vertical resize +1<cr>" : ":vertical resize -1<cr>"', {expr = true})
my.nmap('<down>', 'winnr() == winnr("j") ? ":resize -1<cr>" : ":resize +1<cr>"', {expr = true})
my.nmap('<up>',   'winnr() == winnr("j") ? ":resize +1<cr>" : ":resize -1<cr>"', {expr = true})

-- Global replace
my.nmap('<leader>sr', ':%s/\\<<C-R>=expand("<cword>")<cr>\\>//g<left><left>')

-- Insert path of current file on command-line with %/
my.cmap('%/', '<C-R>=expand("%:p:h")."/"<CR>', {silent = false})

-- Reformat current paragraph
my.nmap('Q', '}{gq}')
my.vmap('Q', 'gq')

-- Reformat current paragraph with 80 textwidth
function reformat_prose(type)
  if type == nil then
    vim.opt.opfunc = 'v:lua.reformat_prose'
    return 'g@' -- calls back to this function
  end

  -- override textwidth, this is the point
  local tw_save = vim.opt.textwidth
  vim.opt.textwidth = 80

  -- boilerplate save, see :help g@
  local cb_save = vim.opt.clipboard
  local sel_save = vim.opt.selection
  local visual_marks_save = {vim.fn.getpos("'<"), vim.fn.getpos("'>")}
  vim.opt.clipboard = ''
  vim.opt.selection = 'inclusive'

  local commands = {
    char = [[`[v`]gw]],
    line = [[`[V`]gw]],
    block = [[`[\<c-v>`]gw]],
  }
  vim.cmd([[noautocmd keepjumps normal! ]] .. commands[type] .. [[gw]])

  -- boilerplate restore
  vim.fn.setreg('"', reg_save)
  vim.fn.setpos("'<", visual_marks_save[0])
  vim.fn.setpos("'>", visual_marks_save[1])
  vim.opt.clipboard = cb_save
  vim.opt.selection = sel_save

  -- restore textwidth
  vim.opt.textwidth = tw_save
end

my.nmap('gw', 'v:lua.my.reformat_prose()', {expr = true})
my.xmap('gw', 'v:lua.my.reformat_prose()', {expr = true})
my.nmap('gwgw', "v:lua.my.reformat_prose() .. '_'", {expr = true})

-- Next and previous buffer
vim.cmd([[
  nmap <tab> <Plug>AirlineSelectNextTab
  nmap <s-tab> <Plug>AirlineSelectPrevTab
]])

-- Stop highlighting matches
my.nmap('<leader><space>', ':nohl<cr>')

------------------------------------------------------------------------
-- Finish
------------------------------------------------------------------------

-- When editing a file, always jump to the last cursor position.
-- This duplicates an autocmd provided by fedora, so clear that.
vim.cmd([[
  augroup user
    augroup fedora!
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    autocmd BufReadPost COMMIT_EDITMSG exe "normal! gg"
  augroup END
]])

-- Load a few personal things.
my.source(vim.fn.expand('~/.vimrc.mine'), {missing_ok = true})
