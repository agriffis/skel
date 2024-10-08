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

my.dump = function(...)
  print(vim.inspect(...))
end

my.prequire = function(...)
  local status, lib = pcall(require, ...)
  return status and lib
end

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
  -- Sometimes this returns 1, sometimes it returns 3.
  -- It seems like a plugin is overriding the default implementation,
  -- but I haven't figured out which, so this baseline assertion is commented
  -- out.
  --assert(f(unpack({ 1, nil, 3 })) == 1)
  assert(f(my.unpork({ 1, nil, 3 }, 3)) == 3)
  assert(f(my.unpork({ 1, nil, nil }, 3)) == 3)
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
    local args = { ... }
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

-- Prepend a to b. Returns new table, does not mutate.
my.prepend = my.curry(function(a, b)
  return vim.tbl_flatten { a, b }
end)

-- Append a to b. Returns new table, does not mutate.
my.append = my.curry(function(a, b)
  return vim.tbl_flatten { b, a }
end)

-- Check if s starts with ss.
my.starts_with = my.curry(function(ss, s)
  return string.sub(s, 1, string.len(ss)) == ss
end)

-- Trim prefix from s.
my.trim_prefix = my.curry(function(prefix, s)
  if my.starts_with(prefix, s) then
    s = string.sub(s, string.len(prefix) + 1)
  end
  return s
end)

function my.compose(...)
  local fns = { ... }
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

function my.source(x, opts)
  local options = my.merge({ missing_ok = false }, opts or {})
  if not x:find('/') then
    x = vim.fn.stdpath('config') .. '/' .. x
  end
  if options.missing_ok and not vim.fn.filereadable(x) then
    return
  end
  vim.cmd('source ' .. x)
end

function my.t(s)
  return vim.api.nvim_replace_termcodes(s, true, true, true)
end

function my.log(msg, hl, name)
  name = name or 'Neovim'
  hl = hl or 'Todo'
  vim.api.nvim_echo({ { name .. ': ', hl }, { msg } }, true, {})
end

function my.info(msg, name)
  vim.notify(msg, vim.log.levels.INFO, { title = name })
end

function my.warn(msg, name)
  vim.notify(msg, vim.log.levels.WARN, { title = name })
end

function my.error(msg, name)
  vim.notify(msg, vim.log.levels.ERROR, { title = name })
end

-- https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils/discussions/109
function my.format_code()
  --local bufnr = vim.api.nvim_get_current_buf()
  --local tsserver_is_attached = false
  --for _, client in ipairs(vim.lsp.buf_get_clients(bufnr)) do
  --  if client.name == "tsserver" then
  --    tsserver_is_attached = true
  --    break
  --  end
  --end
  --if tsserver_is_attached then
  --  local status, err = require('nvim-lsp-ts-utils').organize_imports_sync(bufnr, 2500)
  --  if status then
  --    vim.cmd('undo' .. 'join') -- for some reason undojoin breaks treesitter
  --  else
  --    my.error("organize_imports_sync failed with: " .. err)
  --  end
  --end
  _G.zprint_generator._failed = false
  vim.lsp.buf.format {
    -- Prefer null-ls formatting.
    filter = function(client)
      return client.name ~= 'tsserver' and client.name ~= 'jdtls'
    end,
    timeout_ms = 5000,
  }
end

function my.operator_register(name, fn)
  _G[name] = function(type)
    if type == nil then
      vim.opt.opfunc = 'v:lua.' .. name
      return 'g@' -- calls back to this function
    end

    -- boilerplate save, see :help g@
    local sel_save = vim.opt.selection
    local reg_save = vim.fn.getreginfo('"')
    local cb_save = vim.opt.clipboard
    local visual_marks_save = { vim.fn.getpos("'<"), vim.fn.getpos("'>") }

    -- boilerplate setup
    vim.opt.clipboard = ''
    vim.opt.selection = 'inclusive'

    local status, err = pcall(fn, type)

    -- boilerplate restore
    vim.fn.setreg('"', reg_save)
    vim.fn.setpos("'<", visual_marks_save[0])
    vim.fn.setpos("'>", visual_marks_save[1])
    vim.opt.clipboard = cb_save
    vim.opt.selection = sel_save

    if not status then
      error(err)
    end
  end
end

return my
