-- Try to apply a theme, restoring the current background setting afterward (for
-- themes that default to light or dark but support both)
local function try_theme(theme, bg)
  if theme == 'solarized' then
    bg = 'dark'
  end
  local status, err = pcall(vim.cmd, 'colorscheme ' .. theme)
  if not status then
    -- "Vim(colorscheme):E185: Cannot find color scheme 'foobar'"
    if err:match(':([^:]+)') == 'E185' then
      return
    end
    error(err)
  end
  if bg ~= '' then
    vim.opt.background = bg
  end
  if vim.fn.exists('syntax_on') then
    vim.cmd('syn reset')
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

-- Load theme immediately.
load_theme()

-- Load theme in timer. Wait 3s on init then run every second.
_G.themer_timer = vim.loop.new_timer()
themer_timer:start(3000, 1000, vim.schedule_wrap(load_theme))
