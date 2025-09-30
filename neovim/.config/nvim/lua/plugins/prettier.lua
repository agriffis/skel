-- This is different from https://www.lazyvim.org/extras/formatting/prettier because we use
-- prettierd instead of raw prettier, for speed.

local supported = {
  'css',
  'graphql',
  'handlebars',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'less',
  'markdown',
  'markdown.mdx',
  'scss',
  'typescript',
  'typescriptreact',
  'vue',
  'yaml',
}

return {
  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'prettier', 'prettierd' } },
  },

  {
    'stevearc/conform.nvim',
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = { 'prettierd' }
      end
    end,
  },
}
