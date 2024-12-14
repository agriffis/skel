local function clear_table(t)
  for k, _ in pairs(t) do
    t[k] = nil
  end
end

local function to_keys_object(ka)
  local ko = {}
  for _, a in ipairs(ka) do
    local o = vim.list_slice(a, 2)
    for k, v in pairs(a) do
      if type(k) ~= 'number' then
        o[k] = v
      end
    end
    ko[a[1]] = o
  end
  return ko
end

local function to_keys_list(ko)
  local ka = {}
  for k, o in pairs(ko) do
    local a = vim.list_extend({ k }, o)
    for kk in pairs(o) do
      if type(kk) ~= 'number' then
        a[kk] = o[kk]
      end
    end
    table.insert(ka, a)
  end
  return ka
end

-- https://www.lazyvim.org/extras/editor/fzf
return {
  'ibhagwan/fzf-lua',
  dependencies = {
    { 'junegunn/fzf', build = './install --bin' },
  },
  opts = {
    winopts = {
      preview = {
        layout = 'vertical', -- default is 'flex'
      },
      --X fzf_opts = {
      --X   ['--no-scrollbar'] = true,
      --X   --      ['--ansi'] = true,
      --X   --      ['--exact'] = true,
      --X   --      ['--height'] = '100%',
      --X   --      ['--info'] = 'inline',
      --X   --      ['--keep-right'] = true, -- https://github.com/ibhagwan/fzf-lua/issues/269
      --X   --      ['--layout'] = 'reverse',
      --X   --      ['--prompt'] = '> ',
      --X },
      grep = {
        rg_opts = table.concat({
          '--column',
          '--line-number',
          '--no-heading',
          '--color=always',
          '--smart-case',
          '--max-columns=512',
          '-g !.git',
        }, ' '),
      },
    },
  },
  keys = function(_, plugin_keys)
    local ko = to_keys_object(plugin_keys)

    -- Remove some of the LazyVim defaults
    ko['<leader><space>'] = nil
    ko['<leader>fF'] = nil
    ko['<leader>fb'] = nil
    ko['<leader>,'] = nil

    -- I don't know why this breaks c-j c-k window navigation.
    --ko['<c-j>']

    -- Swap ss/sS in the LazyVim defaults
    ko = vim.tbl_extend('force', ko, {
      ['<leader>ss'] = ko['<leader>sS'], -- LSP workspace symbols
      ['<leader>sS'] = ko['<leader>ss'], -- LSP document symbols
    })

    -- Swap sc/sC in the LazyVim defaults
    ko = vim.tbl_extend('force', ko, {
      ['<leader>sc'] = ko['<leader>sC'], -- Vim command
      ['<leader>sC'] = ko['<leader>sc'], -- Vim command history
    })

    -- Now our preferred bindings. Following work without needing to find
    -- project root because we're always in the project root thanks to
    -- vim-rooter.
    -- stylua: ignore
    ko = vim.tbl_extend('force', ko, {
      ['<leader>bb'] = { function() require('fzf-lua').buffers() end, desc = 'Choose from open buffers' },
      ['<c-p>'] = { function() require('fzf-lua').files() end, desc = 'Open file in project', },
      --['<leader><space>'] = { function() require('fzf-lua').files() end, desc = 'Open file in project', },
      ['<leader>ff'] = { function() require('fzf-lua').files { cwd = vim.fn.expand('%:p:h') } end, desc = 'Open file in current dir', },
      ['<leader>fr'] = { function() require('fzf-lua').oldfiles() end, desc = 'Open recent file', },
      ['<leader>fR'] = { function() require('fzf-lua').oldfiles() end, desc = 'Open recent file', },
      ['<leader>sp'] = { function() require('fzf-lua').live_grep() end, desc = 'Search project', },
      ['<leader>sP'] = { function() require('fzf-lua').live_grep { search = vim.fn.expand('<cword>'), } end, desc = 'Search project (current word)', },
      ['<leader>/'] = { function() require('fzf-lua').live_grep() end, desc = 'Search project' },
      ['<leader>?'] = { function() require('fzf-lua').live_grep { cwd = vim.fn.expand('%:p:h') } end, desc = 'Search current dir' },
      ['<leader>*'] = { function() require('fzf-lua').live_grep { search = vim.fn.expand('<cword>'), } end, desc = 'Search project (current word)', },
      ['<leader>sR'] = { function() require('fzf-lua').resume() end, desc = 'Resume last search' }
    })

    -- Mutate content of plugin_keys
    clear_table(plugin_keys)
    vim.list_extend(plugin_keys, to_keys_list(ko))
  end,
}
