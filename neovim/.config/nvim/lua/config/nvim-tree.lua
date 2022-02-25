local M = {}

function M.config()
  require("nvim-tree").setup({
    disable_netrw = true,
    hijack_netrw = true,
    update_focused_file = {
      enable = true,
    },
  })
  require('my').spacekeys({
    t = {
      f = {'<cmd>NvimTreeToggle<cr>', 'Toggle file explorer'},
    },
  })
end

return M
