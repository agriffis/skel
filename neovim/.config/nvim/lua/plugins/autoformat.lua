-- LazyVim defaults to autoformat on save. This is more aggressive than I want.
-- Instead, disable per buffer by default, then re-enable selectively using
-- a custom property in editorconfig (see the .editorconfig in this repository
-- for example)
--
-- Note that even with autoformat disabled, you can always invoke the formatter
-- directly with <leader>cf

-- Disable autoformat per buffer, to be re-enabled by editorconfig. This is
-- different from disabling autoformat globally, which would prevent us from
-- selectively enabling it per buffer.
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPre' }, {
  group = vim.api.nvim_create_augroup('MyAutoformat', { clear = true }),
  callback = function(event)
    vim.b[event.buf].autoformat = false
  end,
})

-- Recognize editorconfig custom property to enable autoformatting.
require('editorconfig').properties.autoformat = function(bufnr, val)
  vim.b[bufnr].autoformat = val == 'true'
end

return {}
