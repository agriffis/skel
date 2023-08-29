-- https://www.reddit.com/r/neovim/comments/13otw9e/comment/jy8kouz/?utm_source=reddit&utm_medium=web2x&context=3
return {
  {
    'nvim-tree/nvim-web-devicons',
    opts = {
      override = {
        text = { icon = 'T' },
      },
      override_by_extension = {
        txt = { icon = 'T' },
      },
    },
  },
  {
    'akinsho/bufferline.nvim',
    opts = {
      options = {
        show_buffer_close_icons = false,
        show_close_icon = false,
        -- show_buffer_icons = false,
      },
    },
  },
  --[[
  {
    'nvim-lualine/lualine.nvim',
    opts = { options = { icons_enabled = false } },
  },
  ]]
}
