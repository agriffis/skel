-- my.lua
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

local my = {}

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
function my.unpork(t, n, ...)
  if n == 0 then
    return ...
  end
  return my.unpork(t, n - 1, t[n], ...)
end

local function test_unpork()
  local function f(...)
    return select('#', ...)
  end
  assert(f(unpack({1, nil, 3})) == 1)
  assert(f(my.unpork({1, nil, 3}, 3)) == 3)
  assert(f(my.unpork({1, nil, nil}, 3)) == 3)
end
test_unpork()

-- Given a function and arity, return a curried function.
function my.curry(fn, arity)
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
      return fn(my.unpork(args, nargs + select('#', ...)))
    end
    return my.curry(fn2, arity - nargs)
  end
end

local function test_curry()
  local function f(z, y, x, v, w)
    return z, y, x, v, w
  end
  local a, b, c, d, e = my.curry(f)('a', 'b')('c')()('d', 'e')
  assert(a == 'a')
  assert(b == 'b')
  assert(c == 'c')
  assert(d == 'd')
  assert(e == 'e')
end
test_curry()

-- map(fn, tbl) Map a table through a function, returning a new table. Does not
-- modify the original table. Curried for use with compose()
my.map = my.curry(function(fn, t)
  local r = {}
  for k, v in pairs(t) do
    r[k] = fn(v, k, t)
  end
  return r
end)

-- filter(fn, tbl) Filter a table through a function, returning a new table.
-- Does not modify the original table. Curried for use with compose()
my.filter = my.curry(function(fn, t)
  local r = {}
  for k, v in pairs(t) do
    if fn(v, k, t) then
      r[k] = v
    end
  end
  return r
end)

function my.compose(...)
  local fns = {...}
  return function(x)
    for _, fn in ipairs(fns) do
      x = fn(x)
    end
    return x
  end
end

-- Returns new table, does not mutate
function my.merge(...)
  return vim.tbl_extend('force', ...)
end

function my.keymap(mode, lhs, rhs, opts)
  local options = my.merge({noremap = true, silent = true}, opts or {})
  local buffer = options.buffer == true and 0 or options.buffer
  options.buffer = nil
  if buffer then
    vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, options)
  else
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
  end
end

function my.cmap(...) my.keymap('c', ...) end
function my.imap(...) my.keymap('i', ...) end
function my.nmap(...) my.keymap('n', ...) end
function my.vmap(...) my.keymap('v', ...) end
function my.xmap(...) my.keymap('x', ...) end

function my.source(x, opts)
  local options = my.merge({missing_ok = false}, opt or {})
  if not x:find('/') then
    x = vim.fn.stdpath('config') .. '/' .. x
  end
  if missing_ok and not vim.fn.filereadable(x) then
    return
  end
  vim.cmd('source ' .. x)
end

function my.spacekeys(mappings, options)
  options = my.merge({prefix = '<leader>'}, options or {})
  require('which-key').register(mappings, options)
end

return my
