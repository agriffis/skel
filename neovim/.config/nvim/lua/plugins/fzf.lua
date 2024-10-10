local function clear_table(t)
  for k, _ in pairs(t) do
    t[k] = nil
  end
end

local function to_keys_object(ka)
  local ko = {}
  for _, v in ipairs(ka) do
    ko[v[1]] = vim.list_slice(v, 2)
  end
  return ko
end

local function to_keys_list(ko)
  local ka = {}
  for k, v in pairs(ko) do
    table.insert(ka, vim.list_extend({ k }, v))
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

    -- Swap ss/sS in the LazyVim defaults
    ko = vim.tbl_extend('force', ko, {
      ['<leader>ss'] = ko['<leader>sS'],
      ['<leader>sS'] = ko['<leader>ss'],
    })

      -- Now our preferred bindings. Following work without needing to find
      -- project root because we're always in the project root thanks to
      -- vim-rooter.
      -- stylua: ignore
      ko = vim.tbl_extend('force', ko, {
        ['<leader>bb'] = { function() require('fzf-lua').buffers() end, desc = 'Choose from open buffers' },
        ['<c-p>'] = { function() require('fzf-lua').files() end, desc = 'Open file in project', },
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
