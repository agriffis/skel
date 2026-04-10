local my = require('my')

return {
  {
    'LazyVim/LazyVim',
    opts = {
      news = {
        lazyvim = false,
        neovim = false,
      },
    },
  },

  {
    'folke/snacks.nvim',
    opts = {
      dashboard = { enabled = false },
      indent = { enabled = false },
      scroll = { enabled = false },
    },
  },

  -- Show hidden files by default.
  -- https://github.com/LazyVim/LazyVim/discussions/6807#discussioncomment-15038023
  {
    'folke/snacks.nvim',
    opts = {
      picker = {
        hidden = true,
        sources = {
          files = {
            hidden = true,
          },
        },
      },
    },
  },

  -- Close snacks pickers when Esc is pressed.
  -- https://github.com/folke/snacks.nvim/issues/1440
  {
    'folke/snacks.nvim',
    opts = {
      picker = {
        enabled = true,
        win = {
          input = {
            keys = {
              ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
            },
          },
        },
      },
    },
  },

  {
    'folke/snacks.nvim',
    opts = {
      picker = {
        actions = {
          -- Define a new action called 'multi_vsplit'
          multi_vsplit = function(picker)
            local items = picker:selected()
            if #items == 0 then
              items = { picker:current() }
            end
            picker:close()

            -- Identify if the current buffer is a "clean" empty buffer.
            local target_buf = vim.api.nvim_get_current_buf()
            local is_empty = vim.api.nvim_buf_get_name(target_buf) == ''
              and vim.api.nvim_get_option_value('modified', { buf = target_buf }) == false
              and vim.api.nvim_buf_line_count(target_buf) <= 1
              and vim.api.nvim_buf_get_lines(target_buf, 0, 1, false)[1] == ''

            -- Open all selected files.
            local opened_something = false
            for _, item in ipairs(items) do
              -- Ensure the item has a file path before trying to split
              if item.file then
                vim.cmd('vsplit ' .. vim.fn.fnameescape(item.file))
                opened_something = true
              end
            end

            if opened_something then
              -- If we started on an empty buffer, delete it now that we've replaced it.
              if is_empty and vim.api.nvim_buf_is_valid(target_buf) then
                vim.api.nvim_buf_delete(target_buf, { force = true })
              end

              -- Equalize window sizes after opening.
              vim.cmd('wincmd =')

              -- Switch to the leftmost window.
              vim.cmd('999wincmd h')
            end
          end,
        },
        win = {
          input = {
            keys = {
              -- Use ctrl-v to open all selected files in separate vert splits.
              -- This overrides the default ctrl-v binding which only opens a single
              -- vertical split.
              ['<C-v>'] = { 'multi_vsplit', mode = { 'n', 'i' } },
            },
          },
        },
      },
    },
  },

  {
    'folke/snacks.nvim',
    keys = {
      { '<c-p>', LazyVim.pick('files', { root = true }), desc = 'Find Files (Root Dir)' },
      {
        '<leader>ff',
        function()
          return LazyVim.pick.open('files', { cwd = vim.fn.expand('%:p:h') })
        end,
        desc = 'Find Files (cwd)',
      },
      {
        '<leader>*',
        function()
          return LazyVim.pick.open('grep_word')
        end,
        desc = 'Word (Root Dir)',
        mode = { 'n', 'x' },
      },
      -- duplicated from git.lua for now
      --{ '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', desc = 'Diffview current file history' },
      --{ '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview open' },
    },
  },

  {
    'folke/flash.nvim',
    opts = {
      modes = {
        char = { enabled = false },
        search = { enabled = false },
      },
    },
  },

  {
    'saghen/blink.cmp',
    optional = true,
    opts = function(_, opts)
      -- Omit buffer/snippets from default sources, so we're only getting
      -- "smart" completions from LSP etc.
      opts.sources.default = my.filter(function(v)
        return v ~= 'buffer' and v ~= 'snippets'
      end, opts.sources.default)

      -- Don't show completion menu until I press ctrl-space.
      opts.completion.menu.auto_show = false
      opts.completion.ghost_text.show_with_menu = false

      -- Don't consider ghost text "open"
      local function is_open()
        return require('blink.cmp.completion.windows.menu').win:is_open()
      end
      local function if_open_then(cmd)
        return function(cmp)
          return is_open() and cmp[cmd]()
        end
      end
      local function show_menu(cmp)
        if is_open() then
          return
        end
        cmp.show()
        return true
      end

      opts.keymap = {
        preset = 'none',
        ['<C-space>'] = { show_menu, 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<CR>'] = { if_open_then('accept'), 'fallback' },
        ['<Tab>'] = { 'accept', 'fallback' },
        ['<Up>'] = { if_open_then('select_prev'), 'fallback' },
        ['<Down>'] = { if_open_then('select_next'), 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        -- Use ctrl-n/p for normal vim completion unless blink is open.
        ['<C-p>'] = { if_open_then('select_prev'), 'fallback' },
        ['<C-n>'] = { if_open_then('select_next'), 'fallback' },
      }
    end,
  },
}
