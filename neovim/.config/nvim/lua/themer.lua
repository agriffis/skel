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
local my = require('my')

local M = {}

local default_opts = {
  load = function(theme)
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
  end,
  should_syn_reset = true,
}

local theme_opts = {
  solarized = {
    force_bg = 'dark',
  },
  tokyonight = {
    load = function(_, bg)
      require('tokyonight').load {
        style = bg == 'dark' and 'night' or 'day',
        transparent = true,
      }
      return true
    end,
    -- reset causes us to lose our transparency
    should_syn_reset = false,
  },
}

-- Try to apply a theme, restoring the current background setting afterward (for
-- themes that default to light or dark but support both)
local function try_theme(theme, bg)
  local opts = my.merge(default_opts, theme_opts[theme] or {})
  bg = opts.force_bg or bg
  if bg and bg ~= '' then
    vim.opt.background = bg
  end
  if opts.load(theme, bg) then
    if bg and bg ~= '' then
      vim.opt.background = bg
    end
    if opts.should_syn_reset and vim.fn.exists('syntax_on') then
      vim.cmd('syn reset')
    end
  end
end

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

  tried_theme = theme
  tried_bg = bg

  try_theme(theme, bg)
end

function M.setup()
  if not _G.themer_timer then
    -- Load theme immediately.
    load_theme()

    -- Load theme in timer. Wait 3s on init then run every second.
    _G.themer_timer = vim.loop.new_timer()
    themer_timer:start(3000, 1000, vim.schedule_wrap(load_theme))
  end
end

return M
