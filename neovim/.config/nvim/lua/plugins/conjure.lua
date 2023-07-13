local sexp_filetypes = { 'clojure', 'lisp', 'scheme' }

return {
  { 'tpope/vim-classpath', lazy = true, ft = { 'java', 'clojure' } },

  { 'Olical/conjure', lazy = true, ft = { 'clojure' } },

  { 'guns/vim-sexp', lazy = true, ft = sexp_filetypes },

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
      local my = require('my')
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        group = vim.api.nvim_create_augroup('MySexpMappings', { clear = true }),
        pattern = sexp_filetypes,
        callback = function()
          my.nmap(
            '><',
            '<Plug>(sexp_emit_head_element)',
            { buffer = true, desc = 'Emit head element' }
          )
          my.nmap(
            '<>',
            '<Plug>(sexp_emit_tail_element)',
            { buffer = true, desc = 'Emit tail element' }
          )
          my.nmap(
            '<<',
            '<Plug>(sexp_capture_prev_element)',
            { buffer = true, desc = 'Capture previous element' }
          )
          my.nmap(
            '>>',
            '<Plug>(sexp_capture_next_element)',
            { buffer = true, desc = 'Capture next element' }
          )
        end,
      })
    end,
  },
}
