return {
  { 'sindrets/diffview.nvim' },
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'ibhagwan/fzf-lua',
    },
    config = true,
  },
  {
    'tpope/vim-fugitive',
  },
}
