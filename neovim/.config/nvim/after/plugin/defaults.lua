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

-- Set up the clipboard provider first, because the associated settings are
-- sticky; they cannot be reconfigured effectively once set.
my.source('clipboard.vim')

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------
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
vim.opt.timeoutlen = 300      -- ms to wait for a mapped sequence to complete
vim.opt.updatetime = 2000
vim.opt.wildmode = {'longest', 'list', 'full'}
vim.opt.wrap = false

-- Tabs and indents
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

-- Search and completion
vim.opt.complete:remove {'t'} -- don't search tags files by default
vim.opt.complete:remove {'i'} -- don't search included files -- takes too long
vim.opt.ignorecase = true -- "foo" matches "Foo", etc
vim.opt.infercase = true  -- adjust the case of the match with ctrl-p/ctrl-n
vim.opt.smartcase = true  -- ignorecase only when the pattern is all lower
vim.opt.hlsearch = false  -- by default, don't highlight matches after they're found
vim.opt.grepprg = 'rg --hidden --line-number --smart-case --sort-files'

-- Windowing
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.equalalways = true   -- keep windows equal when splitting (default)
vim.opt.eadirection = 'both' -- ver/hor/both - where does equalalways apply
vim.opt.fillchars = 'vert:╎'
vim.opt.winwidth = 40

-- Terminal
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

------------------------------------------------------------------------
-- Mappings
------------------------------------------------------------------------
-- Set the map leaders to SPC and SPC-m similar to Spacemacs.
-- These must be set before referring to <leader> in maps
vim.g.mapleader = ' '
vim.g.maplocalleader = ' m'

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

my.source('themer.vim')

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

