return {
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        -- Linting markdown is too distracting.
        markdown = {
          -- 'markdownlint-cli2'
        },
      },
    },
  },
}
