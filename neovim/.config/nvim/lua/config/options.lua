-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set up the clipboard provider first, because the associated settings are
-- sticky; they cannot be reconfigured effectively once set.
require('clipboard')

--------------------------------------------------------------------------------
-- Augment/override lazyvim settings
--------------------------------------------------------------------------------
vim.opt.backspace = '2' -- allow backspacing over everything in insert mode
vim.opt.backupcopy = 'yes' -- best for inotify
vim.opt.hidden = true -- enable background buffers
vim.opt.history = 100 -- keep 100 lines of command line history
vim.opt.joinspaces = false -- two spaces after a period is for old fogeys
vim.opt.listchars = { tab = '»·', trail = '·' }
vim.opt.modeline = true
vim.opt.modelines = 5
vim.opt.paragraphs = '' -- otherwise NROFF macros screw up CSS
vim.opt.pastetoggle = '<F10>'
vim.opt.relativenumber = false
vim.opt.ruler = true -- show the cursor position all the time
vim.opt.shada = "!,'10,f0,h,s100" -- keep fast by avoiding lots of file/dir stats
vim.opt.warn = false -- don't warn for shell command when buffer changed

-- Tabs and indents
vim.opt.comments = 'b:#,b:##,n:>,fb:-,fb:*'
vim.opt.expandtab = true -- default unless overridden by autocmd
-- formatoptions are in the order presented in fo-table
-- a and w are left out because we set them in muttrc for format=flowed
vim.opt.formatoptions:append { 't' } -- auto-wrap using textwidth (not comments)
vim.opt.formatoptions:append { 'c' } -- auto-wrap comments too
vim.opt.formatoptions:append { 'r' } -- continue the comment header automatically on <CR>
vim.opt.formatoptions:append { 'o' } -- insert comment leader with 'o' or 'O'
vim.opt.formatoptions:append { 'q' } -- allow formatting of comments with gq
-- set formatoptions-=w   " double-carriage-return indicates paragraph
-- set formatoptions-=a   " don't reformat automatically
vim.opt.formatoptions:append { 'n' } -- recognize numbered lists when autoindenting
vim.opt.formatoptions:append { '2' } -- use second line of paragraph when autoindenting
vim.opt.formatoptions:remove { 'v' } -- don't worry about vi compatiblity
vim.opt.formatoptions:remove { 'b' } -- only auto-wrap if entering blank before textwidth
vim.opt.formatoptions:append { 'l' } -- don't break long lines in insert mode
vim.opt.formatoptions:append { '1' } -- don't break lines after one-letter words, if possible
vim.opt.formatoptions:append { 'j' } -- remove a comment leader when joining lines
vim.opt.shiftround = true -- round indent < and > to multiple of shiftwidth
vim.opt.shiftwidth = 2 -- overridden by editorconfig etc.
vim.opt.smarttab = true -- use shiftwidth when inserting <Tab>
vim.opt.tabstop = 8 -- number of spaces that <Tab> in file uses
vim.opt.textwidth = 80 -- by default, although plugins or autocmds can modify

-- Search and completion
vim.opt.complete:remove { 't' } -- don't search tags files by default
vim.opt.complete:remove { 'i' } -- don't search included files -- takes too long
vim.opt.ignorecase = true -- "foo" matches "Foo", etc
vim.opt.infercase = true -- adjust the case of the match with ctrl-p/ctrl-n
vim.opt.smartcase = true -- ignorecase only when the pattern is all lower
vim.opt.hlsearch = false -- by default, don't highlight matches after they're found
vim.opt.grepprg = 'rg --hidden --line-number --smart-case --sort-files'

-- Windowing
vim.opt.fillchars = 'vert:╎' -- disambiguate from tmux
vim.opt.winwidth = 40 -- min width for current window (default 20)

-- Enable bracketed paste everywhere. This would happen automatically on
-- local terms, even with mosh using TERM=xterm*, but doesn't happen
-- automatically in tmux with TERM=screen*. Setting it manually works fine.
if vim.fn.has('gui_running') == 0 and vim.go.t_BE == '' then
  vim.go.t_BE = '\27[?2004h' -- enable
  vim.go.t_BD = '\27[?2004l' -- disable
  vim.go.t_PS = '\27[200~' -- start
  vim.go.t_PE = '\27[201~' -- end
end

-- Set the map leaders to SPC and SPC-m similar to Spacemacs.
-- These must be set before referring to <leader> in maps
vim.g.mapleader = ' '
vim.g.maplocalleader = ' m' -- lazyvim defaults both to ' '
