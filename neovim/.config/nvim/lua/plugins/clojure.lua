local sexp_filetypes = { 'clojure', 'lisp', 'scheme' }

return {
  -- Add clojure to treesitter.
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'clojure' })
      end
    end,
  },

  -- Add zprint to conform.
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        clojure = { 'zprint' },
      },
    },
  },

  { 'tpope/vim-classpath', lazy = true, ft = { 'java', 'clojure' } },

  { 'Olical/conjure', lazy = true, ft = { 'clojure' } },

  {
    'guns/vim-sexp',
    lazy = true,
    ft = sexp_filetypes,
    init = function()
      vim.g.sexp_mappings = {
        sexp_indent = '', -- prefer == bound to conform for zprint
        sexp_indent_top = '', -- don't bind =- either
      }
    end,
  },

  -- TODO the mappings provided by vim-sexp-mappings-for-regular-people
  -- seem to be broken or overridden by which-key, especially word motions.
  {
    'tpope/vim-sexp-mappings-for-regular-people',
    lazy = true,
    ft = sexp_filetypes,
    init = function()
      vim.g.sexp_enable_insert_mode_mappings = 0
      vim.g.sexp_insert_after_wrap = 0
    end,
    config = function()
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        group = vim.api.nvim_create_augroup('MySexpMappings', { clear = true }),
        pattern = sexp_filetypes,
        callback = function()
          vim.keymap.set(
            'n',
            '><',
            '<Plug>(sexp_emit_head_element)',
            { desc = 'Emit head element', buffer = true, silent = true }
          )
          vim.keymap.set(
            'n',
            '<>',
            '<Plug>(sexp_emit_tail_element)',
            { desc = 'Emit tail element', buffer = true, silent = true }
          )
          vim.keymap.set(
            'n',
            '<<',
            '<Plug>(sexp_capture_prev_element)',
            { desc = 'Capture previous element', buffer = true, silent = true }
          )
          vim.keymap.set(
            'n',
            '>>',
            '<Plug>(sexp_capture_next_element)',
            { desc = 'Capture next element', buffer = true, silent = true }
          )
        end,
      })
    end,
  },
}
