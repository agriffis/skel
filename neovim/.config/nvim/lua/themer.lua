-- themer.lua
--
-- Written in 2003-2023 by Aron Griffis <aron@arongriffis.com>
--
-- To the extent possible under law, the author(s) have dedicated all copyright
-- and related and neighboring rights to this software to the public domain
-- worldwide. This software is distributed without any warranty.
--
-- CC0 Public Domain Dedication at
-- http://creativecommons.org/publicdomain/zero/1.0/
--------------------------------------------------------------------------------
local M = {}

---@alias LoadFn fun(theme: string, bg: string, opts: ThemerOpts): boolean

---@class ThemerOpts
---@field force_bg? string
---@field load? LoadFn
---@field should_syn_reset? boolean

---@param theme string
---@return boolean
local function try_colorscheme(theme)
  ---@diagnostic disable-next-line: param-type-mismatch
  local status, err = pcall(vim.cmd, 'colorscheme ' .. theme)
  if status then
    return true
  end
  -- Don't splash error for "Vim(colorscheme):E185: Cannot find color scheme 'foobar'"
  if err ~= nil and err:match(':([^:]+)') ~= 'E185' then
    error(err)
  end
  return false -- it didn't work
end

-- Try to apply a theme, restoring the current background setting afterward (for
-- themes that default to light or dark but support both)
---@type LoadFn
local function default_load(theme, bg, opts)
  bg = opts.force_bg or bg
  if bg and bg ~= '' then
    vim.opt.background = bg
  end
  if try_colorscheme(theme) then
    if bg and bg ~= '' then
      vim.opt.background = bg
    end
    if opts.should_syn_reset and vim.fn.exists('syntax_on') then
      vim.cmd('syn reset')
    end
    return true
  end
  return false
end

---@type table<string, ThemerOpts>
local theme_opts = {
  solarized = {
    force_bg = 'dark',
  },
}

local bg_file = vim.fn.expand('~/.vim/background')
local theme_file = vim.fn.expand('~/.vim/theme')
local tried_theme, tried_bg

-- Load theme and background from files that are written by some scheme-changing
-- tool.
local function load_theme()
  local bg = vim.fn.filereadable(bg_file) == 1 and vim.fn.readfile(bg_file)[1] or ''
  local theme = vim.fn.filereadable(theme_file) == 1 and vim.fn.readfile(theme_file)[1] or 'default'

  -- If we're already set this theme/bg combination, don't do it again. This
  -- allows things like :colorscheme and :set bg to work without being
  -- constantly toggled back by this script.
  if theme == tried_theme and bg == tried_bg then
    return
  end

  --- Update globals
  tried_theme = theme
  tried_bg = bg

  local opts = theme_opts[theme] or {}
  local load = opts.load or default_load
  return load(theme, bg, opts)
end

function M.setup()
  if not M.themer_timer then
    -- Load theme immediately.
    load_theme()

    -- Load theme in timer. Wait 3s on init then run every second.
    M.themer_timer = vim.uv.new_timer()
    M.themer_timer:start(3000, 1000, vim.schedule_wrap(load_theme))
  end
end

return M
