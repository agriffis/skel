local M = {}

local configs = {
  'config/lsp/installer',
  'config/lsp/null-ls'
}

local function each_config(name, ...)
  for _, c in ipairs(configs) do
    local fn = require(c)[name]
    if fn then fn(...) end
  end
end

function M.setup()
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      signs = false,
      underline = true,
      virtual_text = false,
    }
  )
  each_config('setup')
end

local function on_attach(client, bufnr)
  each_config('on_attach', client, bufnr)
end

function M.config()
  each_config('config', {on_attach = on_attach})
end

return M
