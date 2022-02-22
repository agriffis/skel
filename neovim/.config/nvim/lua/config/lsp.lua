local M = {}

function M.setup()
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      signs = false,
      underline = true,
      virtual_text = false,
    }
  )
  vim.cmd([[
    augroup my_lsp
      autocmd!
      " Underlining doesn't look good in tmux, which changes the curly
      " underlines to plain. Instead rely on PaperColor to set the
      " background colors.
      autocmd ColorScheme PaperColor hi SpellBad cterm=NONE gui=NONE
      autocmd ColorScheme PaperColor hi SpellCap cterm=NONE gui=NONE
      autocmd ColorScheme PaperColor hi SpellRare cterm=NONE gui=NONE
      autocmd ColorScheme PaperColor hi link LspDiagnosticsUnderlineError SpellBad
      autocmd ColorScheme PaperColor hi link LspDiagnosticsUnderlineWarning SpellCap
      autocmd ColorScheme PaperColor hi link LspDiagnosticsUnderlineHint SpellRare
      autocmd ColorScheme PaperColor hi link LspDiagnosticsUnderlineInformation SpellRare
    augroup END
  ]])
end

function M.config()
  local lspconfig = require('lspconfig')
  local my = require('my')

  local on_lsp_attach = function(client, bufnr)
    local function setlocal(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    for lhs, rhs in pairs({
      gA = 'code_action',
      gD = 'declaration',
      gd = 'definition',
      K = 'hover',
      gi = 'implementation',
      ['<c-k>'] = 'signature_help',
      gt = 'type_definition',
      gr = 'references',
      gR = 'rename',
      g0 = 'document_symbol',
      gW = 'workspace_symbol',
    }) do
      my.nmap(lhs, '<cmd>lua vim.lsp.buf.' .. rhs .. '()<CR>', {buffer = bufnr, silent = true})
    end
    my.nmap('ge', '<cmd>lua vim.lsp.diagnostic.show_position_diagnostics()<cr>')
    my.nmap('[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>')
    my.nmap(']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>')
    my.nmap('<leader>e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>')
    my.nmap('<leader>E', '<cmd>lua vim.lsp.diagnostic.set_qflist()<cr>')
    setlocal('omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.opt.completeopt:remove {'preview'} -- completeopt is global, not buffer-local
  end
  for _, entry in ipairs({
    {lsp = 'cssls', exe = 'css-languageserver'},
    {lsp = 'jdtls'},
    {lsp = 'tsserver', exe = 'typescript-language-server'},
    {lsp = 'vuels', exe = 'vls'},
  }) do
    if entry.exe == nil or vim.fn.executable(entry.exe) == 1 then
      lspconfig[entry.lsp].setup(my.merge({on_attach = on_lsp_attach}, entry.opts or {}))
    end
  end
end

return M
