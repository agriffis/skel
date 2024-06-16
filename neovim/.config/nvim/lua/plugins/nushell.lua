return {
  {
    'lhkipp/nvim-nu',
    build = ':TSInstall nu',
    ft = { 'nu' },
    init = function()
      vim.filetype.add { extension = { nu = 'nu' } }
    end,
  },
}
