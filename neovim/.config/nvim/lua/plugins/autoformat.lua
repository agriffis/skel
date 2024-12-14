-- LazyVim defaults to autoformat on save. This is more aggressive than I want.
-- Instead, disable per buffer by default, then re-enable selectively using
-- a custom property in editorconfig (see the .editorconfig in this repository
-- for example)
--
-- Note that even with autoformat disabled, you can always invoke the formatter
-- directly with <leader>cf

-- Disable autoformat globally, to be re-enabled per-buffer by editorconfig.
-- This works because LazyVim honors the buffer setting in priority over the
-- global setting if it is non-nil.
vim.g.autoformat = false

-- Recognize editorconfig custom property to enable autoformatting.
require('editorconfig').properties.autoformat = function(bufnr, val)
  vim.b[bufnr].autoformat = val == 'true'
end

return {}
