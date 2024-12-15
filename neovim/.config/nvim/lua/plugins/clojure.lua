-- Replicating https://www.lazyvim.org/extras/lang/clojure without the bugs

local lisp_filetypes = { 'clojure', 'fennel', 'lisp', 'scheme' }

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
          -- https://github.com/echasnovski/mini.pairs/blob/main/doc/mini-pairs.txt
          vim.b.minipairs_disable = true
        end,
      })
    end,
  },

  -- Static clojure LSP.
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        clojure_lsp = {},
      },
    },
  },

  -- Dynamic clojure dev with nrepl.
  {
    'Olical/conjure',
    event = 'LazyFile',
    config = function(_, opts)
      -- Enable conjure to respect .nrepl-host.
      -- https://github.com/Olical/conjure/discussions/594
      local _, content = pcall(vim.fn.readfile, '.nrepl-host', '', 1)
      if content then
        vim.g['conjure#client#clojure#nrepl#connection#default_host'] = content[1]
      end
      require('conjure.main').main()
      require('conjure.mapping')['on-filetype']()
    end,
    init = function()
      -- Prefer LSP for jump-to-definition and symbol-doc, and use conjure
      -- alternatives with <localleader>K and <localleader>gd
      vim.g['conjure#mapping#doc_word'] = 'K'
      vim.g['conjure#mapping#def_word'] = 'gd'

      -- Disable the popup HUD. It never has enough info.
      vim.g['conjure#log#hud#enabled'] = false

      -- Enable folding of results when they exceed 10 lines.
      vim.g['conjure#log#fold#enabled'] = true

      -- Jump to top of latest result.
      vim.g['conjure#log#jump_to_latest#enabled'] = true

      -- Enable "go to definition" and "eval file" when connecting to nrepl inside vagrant VM.
      -- The dot works because of vim-rooter.
      vim.g['conjure#path_subs'] = { ['/home/agilepublisher/cubchicken'] = '.' }

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
