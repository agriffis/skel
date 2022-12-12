local M = {}

local configs = {
  'config/lsp/lspconfig',
  'config/lsp/null-ls'
}

local function each_config(name, ...)
  for _, c in ipairs(configs) do
    local fn = require(c)[name]
    if fn then fn(...) end
  end
end

local function on_attach(client, bufnr)
  each_config('on_attach', client, bufnr)
end

function M.config()
  each_config('config', {on_attach = on_attach})
end

return M
