-- clipboard.lua
--
-- Written in 2003-2022 by Aron Griffis <aron@arongriffis.com>
--
-- To the extent possible under law, the author(s) have dedicated all copyright
-- and related and neighboring rights to this software to the public domain
-- worldwide. This software is distributed without any warranty.
--
-- CC0 Public Domain Dedication at
-- http://creativecommons.org/publicdomain/zero/1.0/
--------------------------------------------------------------------------------
local my = require('my')

-- Each time content is copied to the clipboard provider, we'll stash the
-- regtype (V/v/b) in this file, along with a checksum for the content. When we
-- paste it back, if the checksum matches, we can restore the regtype. Why would
-- it not match? If something else saves to the clipboard outside of Vim. In
-- that case we guess at the regtype.
local regtype_file = vim.fn.stdpath('cache') .. '/clipboard_regtype.json'

-- If the external clipboard provider fails, for example over SSH without tmux,
-- so there's no clipboard available, we'll lose the content entirely. To avoid
-- that, save in our own faux register.
local faux_reg

local function copy_provider(copiers)
  local cmd = {'clipboard-provider', 'copy'}

  if copiers then
    cmd = my.prepend({
      'env',
      -- Doesn't need quotes, because no shell.
      'COPY_PROVIDERS=' .. table.concat(copiers, ' '),
    }, cmd)
  end

  return function(lines, regtype)
    -- No matter what happens with the clipboard provider, save the fallback.
    faux_reg = {lines, regtype}

    -- Call the actual clipboard provider now. Do this even if saving the
    -- regtype might fail, because the end result will be pasting in the
    -- default linewise mode.
    vim.fn.systemlist(cmd, lines, 1)
    if vim.v.shell_error ~= 0 then
      return
    end

    -- Save the regtype to a file, along with the checksum of the lines.
    -- Then when we paste, we can restore the regtype if the checksum still
    -- matches. Regtype will be one of:
    --    v for charwise text
    --    V for linewise text
    --    b for blockwise-visual text
    local checksum = vim.fn.sha256(table.concat(lines, '\n'))
    local success = pcall(
      vim.fn.writefile,
      {vim.json.encode({
        checksum = checksum,
        regtype = regtype,
      })},
      regtype_file,
      'S'
    )
    if not success then
      my.warn("clipboard: couldn't save regtype")
    end
  end
end

local function paste_provider(pasters)
  local cmd = {'clipboard-provider', 'paste'}

  if pasters then
    cmd = my.prepend({
      'env',
      -- Doesn't need quotes, because no shell.
      'PASTE_PROVIDERS=' .. table.concat(pasters, ' '),
    }, cmd)
  end

  return function()
    -- Get clipboard content from provider.
    local lines = vim.fn.systemlist(cmd, {}, 1)
    if vim.v.shell_error == 0 then
      -- Restore the regtype, if the checksum matches.
      local regtype = 'V' -- default
      local _, json_lines = pcall(vim.fn.readfile, regtype_file)
      if json_lines then
        local _, info = pcall(vim.json.decode, table.concat(json_lines))
        local checksum = vim.fn.sha256(table.concat(lines, '\n'))
        if info.checksum == checksum then
          regtype = info.regtype
        end
      end
      return {lines, regtype}
    end

    -- Clipboard provider failed, restore from faux_reg.
    return faux_reg or {{''}, 'v'}
  end
end

vim.g.clipboard = {
  copy = {
    ['+'] = copy_provider(),
    ['*'] = copy_provider({'tmux'}),
  },
  paste = {
    ['+'] = paste_provider(),
    ['*'] = paste_provider({'tmux'}),
  },
}

-- Lower y yank to/from * by default (tmux only, not system)
vim.opt.clipboard = 'unnamed'

-- Upper Y yank to system clipboard
my.nmap('YY', '"+yy')
my.nmap('Y', '"+y')
my.vmap('Y', '"+y')
