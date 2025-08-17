-- Replicating https://www.lazyvim.org/extras/lang/clojure without the bugs

local lisp_filetypes = { 'clojure', 'fennel', 'lisp', 'scheme' }

local clojure_root_markers = {
  'bb.edn',
  'build.boot',
  'deps.edn',
  'pom.xml',
  'project.clj',
  'shadow-cljs.edn',
}

return {
  -- Syntax parsing for clojure.
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = { 'clojure' },
    },
  },

  -- Paredit!
  -- https://github.com/julienvincent/nvim-paredit?tab=readme-ov-file
  {
    'julienvincent/nvim-paredit',
    ft = lisp_filetypes,
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = lisp_filetypes,
        callback = function()
          -- Disable default mini.ai textobjects in favor of nvim-paredit's
          -- element/form/top-level-form.
          -- https://github.com/echasnovski/mini.ai/blob/main/doc/mini-ai.txt
          vim.b.miniai_config = {
            custom_textobjects = {
              -- These are on the right track, but they don't work yet, in other
              -- words this will disable but doesn't *enable* the paredit
              -- mapping. I think that the right answer might actually be to
              -- define these according to mini.ai's expectations, either using
              -- the mini.ai-provided internals or what's provided by
              -- nvim-paredit.
              --
              -- For now, the mini.ai-provided ab ("balanced
              -- parens/brackets/braces") already works pretty well.
              --
              --['e'] = false, -- not actually mapped by mini.ai
              --['f'] = false,
              --['F'] = false,
            },
          }
        end,
      })
    end,
    opts = function()
      local api = require('nvim-paredit.api')
      -- Two problems with the following:
      -- 1. It's not effective. Something overrides. Maybe need to use lazyvim's
      --    top-level keys.
      -- 2. Some of the funcs don't exist yet, see
      --    https://github.com/julienvincent/nvim-paredit/issues/86
      --return {
      --  keys = {
      --    ['w'] = {
      --      api.move_to_next_element_head,
      --      'Next element head',
      --      repeatable = false,
      --      mode = { 'n', 'x', 'o', 'v' },
      --    },
      --    ['b'] = {
      --      api.move_to_prev_element_head,
      --      'Previous element head',
      --      repeatable = false,
      --      mode = { 'n', 'x', 'o', 'v' },
      --    },
      --    ['e'] = {
      --      api.move_to_next_element_tail,
      --      'Next element tail',
      --      repeatable = false,
      --      mode = { 'n', 'x', 'o', 'v' },
      --    },
      --    ['ge'] = {
      --      api.move_to_prev_element_tail,
      --      'Previous element tail',
      --      repeatable = false,
      --      mode = { 'n', 'x', 'o', 'v' },
      --    },
      --    --['W'] = {
      --    --  api.move_to_next_form_start,
      --    --  'Next form start',
      --    --  repeatable = false,
      --    --  mode = { 'n', 'x', 'o', 'v' },
      --    --},
      --    --['E'] = {
      --    --  api.move_to_next_form_end,
      --    --  'Next form end',
      --    --  repeatable = false,
      --    --  mode = { 'n', 'x', 'o', 'v' },
      --    --},
      --    --['gE'] = {
      --    --  api.move_to_prev_form_end,
      --    --  'Previous form end',
      --    --  repeatable = false,
      --    --  mode = { 'n', 'x', 'o', 'v' },
      --    --},
      --  },
      --}
    end,
  },

  -- N.B. disabled in overrides.lua in favor of nvim-autopairs.
  {
    'echasnovski/mini.pairs',
    opts = {
      -- These options are provided by LazyVim's plugin/coding.lua, not by
      -- mini.pairs upstream. Disable them because they make LISP editing
      -- harder. There doesn't seem to be an easy way to make this depend on the
      -- filetype.
      -- Don't skip autopair based on next character.
      skip_next = false,
      -- Don't skip autopair even inside strings.
      skip_ts = false,
      -- Don't skip autopair even when next char is closing pair.
      skip_unbalanced = false,
    },
  },

  -- Static clojure LSP.
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        clojure_lsp = {
          filetypes = lisp_filetypes,
          -- Two different root-finding functions available to us:
          --
          -- require('lspconfig.util').root_pattern(...) looks for each file individually, so
          -- it will prioritize /foo/.git over /foo/bar/deps.edn.
          --
          -- vim.fs.find() looks for all files at once, so it stops at the first found.
          root_dir = function(fname)
            local cwd = vim.fs.dirname(fname)
            local found = vim.fs.find(clojure_root_markers, {
              path = cwd,
              upward = true,
            })[1]
            return found and vim.fs.dirname(found) or cwd
          end,
        },
      },
    },
  },

  -- Dynamic clojure dev with nrepl.
  {
    'Olical/conjure',
    branch = 'main',
    ft = lisp_filetypes,
    config = function(_, opts)
      -- Enable "go to definition" and "eval file" when connecting to nrepl inside vagrant VM.
      local project_root = LazyVim.root()
      vim.g['conjure#path_subs'] = { ['/home/agilepublisher/cubchicken'] = project_root }

      -- Enable conjure to respect .nrepl-host.
      -- https://github.com/Olical/conjure/discussions/594
      local conjure_root = vim.fs.root(0, clojure_root_markers) or project_root
      local _, content = pcall(vim.fn.readfile, vim.fs.joinpath(conjure_root, '.nrepl-host'), '', 1)
      if content then
        vim.g['conjure#client#clojure#nrepl#connection#default_host'] = content[1]
      end

      require('conjure.main').main()
      require('conjure.mapping')['on-filetype']()
    end,
    init = function()
      -- Prefer LSP for jump-to-definition and symbol-doc, and use conjure
      -- alternatives with <localleader>K and <localleader>gd
      --vim.g['conjure#mapping#doc_word'] = 'K'
      --vim.g['conjure#mapping#def_word'] = 'gd'

      -- Disable the popup HUD. It never has enough info.
      vim.g['conjure#log#hud#enabled'] = false

      -- Enable folding of results when they exceed 10 lines.
      vim.g['conjure#log#fold#enabled'] = true

      -- Jump to top of latest result.
      vim.g['conjure#log#jump_to_latest#enabled'] = true

      -- Don't start babashka if nrepl isn't available.
      vim.g['conjure#client#clojure#nrepl#connection#auto_repl#enabled'] = false
    end,
  },

  -- Autocomplete with conjure.
  {
    'hrsh7th/nvim-cmp',
    optional = true,
    dependencies = { 'PaterJason/cmp-conjure' },
    opts = function(_, opts)
      table.insert(opts.sources, { name = 'conjure' })
    end,
  },
  {
    'saghen/blink.cmp',
    optional = true,
    dependencies = { 'PaterJason/cmp-conjure', 'saghen/blink.compat' },
    opts = {
      sources = {
        compat = { 'conjure' },
        providers = { conjure = { kind = 'Conjure' } },
      },
      appearance = { kind_icons = { Conjure = '🪄' } },
    },
  },

  -- Use zprint for clojure formatting.
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        clojure = { 'zprint' },
      },
    },
  },

  -- Make sure this fd-leaking monstrosity is disabled.
  {
    'm00qek/baleia.nvim',
    enabled = false,
  },

  -- Set vim file search path from the java classpath.
  -- Temporarily disabled to see if we miss this.
  --{ 'tpope/vim-classpath', lazy = true, ft = { 'java', 'clojure' } },
}
