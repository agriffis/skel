-- caboose.lua
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

-- Continuously sync theme with desktop/terminal scheme (dark/light)
my.source('themer.vim')

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

-- Insert path of current file on command-line with %/
my.cmap('%/', '<C-R>=expand("%:p:h")."/"<CR>', {silent = false})

-- Reformat current paragraph
--my.nmap('Q', '}{gq}')
--my.vmap('Q', 'gq')

-- Reformat current paragraph with 80 textwidth
my.operator_register('op_reformat_prose', function(type)
  -- Save textwidth then override.
  local tw_save = vim.opt.textwidth
  vim.opt.textwidth = 80

  -- Convert motion to visual.
  local commands = {
    char = [[`[v`]gw]],
    line = [[`[V`]gw]],
    block = [[`[\<c-v>`]gw]],
  }
  vim.cmd('noautocmd keepjumps normal! ' .. commands[type] .. 'gw')

  -- Restore textwidth.
  vim.opt.textwidth = tw_save
end)

my.nmap('gw', 'v:lua.op_reformat_prose()', {expr = true})
my.xmap('gw', 'v:lua.op_reformat_prose()', {expr = true})
my.nmap('gwgw', "v:lua.op_reformat_prose() .. '_'", {expr = true})

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
