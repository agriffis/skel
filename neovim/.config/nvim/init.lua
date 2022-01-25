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
local function unpork(t, n, ...)
  if n == 0 then
    return ...
  end
  return unpork(t, n - 1, t[n], ...)
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

-- Returns new table, does not mutate
local function merge(...)
  return vim.tbl_extend('force', ...)
end

local function keymap(mode, lhs, rhs, opts)
  local options = merge({noremap = true}, opts or {})
  local buffer = options.buffer == true and 0 or options.buffer
  options.buffer = nil
  if buffer then
    vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, options)
  else
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
  end
end

local function cmap(...) keymap('c', ...) end
local function imap(...) keymap('i', ...) end
local function nmap(...) keymap('n', ...) end
local function vmap(...) keymap('v', ...) end
local function xmap(...) keymap('x', ...) end

my = {
  -- Make these callable by other files like lua/plugins.lua
  merge = merge,
  cmap = cmap,
  imap = imap,
  nmap = nmap,
  vmap = vmap,
  xmap = xmap,
}

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------
vim.cmd('source ' .. vim.fn.stdpath('config') .. '/clipboard.vim')

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

------------------------------------------------------------------------
-- Load lua/plugins.lua alongside this file
------------------------------------------------------------------------
require('plugins')

------------------------------------------------------------------------
-- Theming
------------------------------------------------------------------------
vim.cmd('source ' .. vim.fn.stdpath('config') .. '/themer.vim')

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

my.reformat_paragraph = function(type)
  if type == nil then
    vim.opt.opfunc = 'v:lua.my.reformat_paragraph'
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

nmap('gw', 'v:lua.my.reformat_paragraph()', {expr = true})
xmap('gw', 'v:lua.my.reformat_paragraph()', {expr = true})
nmap('gwgw', "v:lua.my.reformat_paragraph() .. '_'", {expr = true})

-- Next and previous buffer
vim.cmd([[
  nmap <tab> <Plug>AirlineSelectNextTab
  nmap <s-tab> <Plug>AirlineSelectPrevTab
]])

-- Stop highlighting matches
nmap('<leader><space>', ':nohl<cr>')

------------------------------------------------------------------------
-- Final
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

-- Load plugins now to prevent conflict with those that modify &bin
vim.cmd('runtime! plugin/*.vim')

if vim.fn.filereadable(vim.fn.expand('~/.vimrc.mine')) == 1 then
  vim.cmd('source ~/.vimrc.mine')
end
