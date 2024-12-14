-- Intended to work with https://www.lazyvim.org/extras/lang/astro
-- since we use prettierd instead of prettier (see prettier.lua)

return {
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = {
      formatters_by_ft = {
        astro = { 'prettier' },
      },
    },
  },
}
