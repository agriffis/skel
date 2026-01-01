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

  {
    'MeanderingProgrammer/render-markdown.nvim',
    -- https://github.com/MeanderingProgrammer/render-markdown.nvim?tab=readme-ov-file#setup
    -- https://www.lazyvim.org/extras/lang/markdown#render-markdownnvim
    config = {
      heading = {
        border = true,
        border_virtual = true,
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        position = 'inline',
        sign = true,
      },
      pipe_table = {
        preset = 'round',
        border_enabled = true,
        border_virtual = true,
      },
    },
  },
}
