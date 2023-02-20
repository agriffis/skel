local M = {}

M.servers = {
  cssls = {},
  html = {},
  intelephense = {},
  jdtls = {},
  jsonls = {},
  pyright = {},
  rust_analyzer = {},
--sumneko_lua = {
--  settings = {
--    Lua = {
--      runtime = {
--        version = 'LuaJIT',
--        path = vim.split(package.path, ';'),
--      },
--      diagnostics = {
--        globals = {'vim'},
--      },
--      workspace = {
--        library = {
--          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
--          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
--        },
--      },
--    },
--  },
--},
  tsserver = {
    -- :h lspconfig-setup
    -- The `settings` table is sent in `on_init` via
    -- a `workspace/didChangeConfiguration` notification from the Nvim client to
    -- the language server. These settings allow a user to change optional
    -- runtime settings of the language server. 
    settings = {
      -- https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
      diagnostics = {
        ignoredCodes = {
          80006, -- "This may be converted to an async function."
        },
      },
    },
  },
  vimls = {},
  vuels = {},
}

-- This gets called multiple times, once for each client that attaches to
-- a buffer.
function M.on_attach(client, bufnr)
  local my = require('my')

  local function setlocal(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion with <c-x><c-o>.
  if client.name ~= 'null-ls' then
    setlocal('omnifunc', 'v:lua.vim.lsp.omnifunc')
  end

  -- completeopt is global, not buffer-local
  vim.opt.completeopt:remove {'preview'}

  -- Use LSP as the formatter with gq.
  -- I have no idea how this is SUPPOSED to work, but it doesn't seem to.
  -- Instead use op_format_code below.
  --setlocal('formatexpr', 'v:lua.vim.lsp.formatexpr()')

  if client.name ~= 'null-ls' then
    require('which-key').register({
      -- gd is overridden for TypeScript below
      gd = {'<cmd>lua vim.lsp.buf.definition()<cr>', 'Jump to definition'},
      gD = {'<cmd>lua vim.lsp.buf.type_definition()<cr>', 'Jump to type definition'},
      gi = {'<cmd>lua vim.lsp.buf.implementation()<cr>', 'Jump to implementation'},
      gs = {'<cmd>lua vim.lsp.buf.references()<cr>', 'Show references'},
      gS = {'<cmd>lua vim.lsp.buf.document_symbol()<cr>', 'Show all symbols in document'},
      gW = {'<cmd>lua vim.lsp.buf.workspace_symbol()<cr>', 'Show all symbols in workspace'},
      ga = {'<cmd>lua vim.lsp.buf.code_action()<cr>', 'Choose from available code actions'},
      gr = {'<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol'},
      ge = {'<cmd>lua vim.diagnostic.open_float({scope = "c"})<cr>', 'Show diagnostics at cursor'},
      ['[e'] = {'<cmd>lua vim.diagnostic.goto_prev()<cr>', 'Jump to previous diagnostic'},
      [']e'] = {'<cmd>lua vim.diagnostic.goto_next()<cr>', 'Jump to next diagnostic'},
      ['<leader>e'] = {'<cmd>lua vim.diagnostic.setloclist()<cr>', 'Diagnostics in location list'},
      ['<leader>E'] = {'<cmd>lua vim.diagnostic.setqflist()<cr>', 'Diagnostics in quickfix list'},
      K = {'<cmd>lua vim.lsp.buf.hover()<cr>', 'Show hover info'},
      ['<c-k>'] = {'<cmd>lua vim.lsp.buf.signature_help()<cr>', 'Show signature help'},
      -- Q = {my.format_code, 'Format buffer'},
      ['<leader>=b'] = {my.format_code, 'Format buffer'},
      gwa = {'<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', 'Add folder to workspace'},
      gwr = {'<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', 'Remove folder from workspace'},
    }, {buffer = bufnr})
  end

  require('which-key').register({
    ['<leader>=b'] = {my.format_code, 'Format buffer'},
  }, {buffer = bufnr})

  -- Range formatting via motion.
  -- https://github.com/neovim/neovim/issues/14680
  my.operator_register('op_format_code', function(type)
    vim.lsp.buf.format {
      range = {
        ['start'] = vim.api.nvim_buf_get_mark(0, '['),
        ['end'] = vim.api.nvim_buf_get_mark(0, ']'),
      },
    }
  end)

  --my.nmap('gq', 'v:lua.op_format_code()', {expr = true})
  --my.xmap('gq', 'v:lua.op_format_code()', {expr = true})
  --my.nmap('gqq', "v:lua.op_format_code() .. '_'", {expr = true})
  --my.nmap('gqgq', "v:lua.op_format_code() .. '_'", {expr = true})

  my.nmap('<leader>=', 'v:lua.op_format_code()', {expr = true})
  my.xmap('<leader>=', 'v:lua.op_format_code()', {expr = true})
  my.nmap('<leader>==', "v:lua.op_format_code() .. '_'", {expr = true})

  -- https://github.com/jose-elias-alvarez/typescript.nvim#features
  if client.name == 'tsserver' then
    require('which-key').register({
      gd = {'<cmd>TypescriptGoToSourceDefinition<cr>', 'Go to source definition'},
      gI = {'<cmd>TypescriptAddMissingImports<cr>', 'Auto-import all missing symbols'},
      gO = {'<cmd>TypescriptOrganizeImports<cr>', 'Organize imports'},
      gR = {'<cmd>TypescriptRenameFile<cr>', 'Rename file'},
    }, {buffer = bufnr})
  end

  -- Prefer null-ls formatting.
  if client.name == 'tsserver' or client.name == 'jdtls' then
    client.server_capabilities.document_formatting = false
  end
end

-- This gets called once, from config/lsp/init.lua
function M.config(options)
  local my = require('my')

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      signs = false,
      underline = true,
      virtual_text = false,
    }
  )

  for _, name in ipairs(require('mason-lspconfig').get_installed_servers()) do
    local server = require('lspconfig')[name]
    if server then
      local opts = my.merge(options or {}, M.servers[name] or {})
      if name == 'tsserver' then
        -- This replaces calling server.setup(opts)
        -- https://github.com/jose-elias-alvarez/typescript.nvim#setup
        require('typescript').setup({server = opts})
      else
        if name == 'sumneko_lua' then
          -- Call before calling server.setup()
          -- https://github.com/folke/neodev.nvim#-setup
          require('neodev').setup {}
        end
        server.setup(opts)
      end
    end
  end
end

return M
