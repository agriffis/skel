local html_ft = { 'html', 'markdown' }
local all_ft = vim.list_extend({ 'javascriptreact', 'typescriptreact', 'vue', 'xml' }, html_ft)

-- This plugin isn't awesome but I haven't found another one that works better.
-- The best bet is https://github.com/windwp/nvim-ts-autotag but it seems to
-- have a lot of issues.
return {
  'agriffis/closetag.vim',
  config = function()
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
}
