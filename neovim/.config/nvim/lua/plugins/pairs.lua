return {
  -- Replace mini.pairs with nvim-autopairs
  -- https://github.com/LazyVim/LazyVim/discussions/2248
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'nvim-mini/mini.pairs',
    enabled = false,
  },

  -- Tag closing plugins.
  {
    'windwp/nvim-ts-autotag',
    -- enabled = false,
    opts = {
      autotag = {
        -- Disable auto close on slash, instead ctrl-/ inserts the closing tag
        -- via closetag plugin below.
        -- https://github.com/windwp/nvim-ts-autotag/issues/124
        -- https://github.com/windwp/nvim-ts-autotag/issues/125
        -- https://github.com/windwp/nvim-ts-autotag/issues/151
        enable_close_on_slash = false,
      },
    },
  },
  {
    'agriffis/closetag.vim',
    config = function()
      local html_ft = { 'html', 'markdown' }
      local all_ft =
        vim.list_extend({ 'javascriptreact', 'typescriptreact', 'vue', 'xml' }, html_ft)
      -- The closetag.vim script is kinda broken... it requires
      -- b:unaryTagsStack per buffer but only sets it once, on script load.
      local group = vim.api.nvim_create_augroup('MyCloseTag', { clear = true })
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        group = group,
        pattern = all_ft,
        callback = function(event)
          if vim.list_contains(html_ft, event.match) then
            vim.b[event.buf].unaryTagsStack = 'area base br dd dt hr img input link meta param'
          else
            vim.b[event.buf].unaryTagsStack = ''
          end
          vim.cmd([[inoremap <buffer> <c-/> <c-r>=GetCloseTag()<cr>]])
        end,
      })
    end,
  },
}
