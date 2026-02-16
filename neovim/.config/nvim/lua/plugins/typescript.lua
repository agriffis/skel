local my = require('my')

return {
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      vim.list_extend(
        opts.inlay_hints.exclude,
        { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
      )
    end,
  },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        --- Disable tsserver and ts_ls in favor of vtsls and tsgo.
        --- https://www.lazyvim.org/extras/lang/typescript
        --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/tsgo.lua

        tsserver = { enabled = false }, -- normally disabled in lazyvim
        ts_ls = { enabled = false }, -- normally disabled in lazyvim

        -- Keep using vtsls but only for the features we want.
        --vtsls = {},

        --- see https://www.lazyvim.org/extras/lang/typescript
        --- and https://www.lazyvim.org/extras/lang/typescript
        tsgo = {
          keys = {
            {
              'gD',
              function()
                local win = vim.api.nvim_get_current_win()
                local params = vim.lsp.util.make_position_params(win, 'utf-16')
                LazyVim.lsp.execute {
                  command = 'typescript.goToSourceDefinition',
                  arguments = { params.textDocument.uri, params.position },
                  open = true,
                }
              end,
              desc = 'Goto Source Definition',
            },
            {
              'gR',
              function()
                LazyVim.lsp.execute {
                  command = 'typescript.findAllFileReferences',
                  arguments = { vim.uri_from_bufnr(0) },
                  open = true,
                }
              end,
              desc = 'File References',
            },
            {
              '<leader>co',
              LazyVim.lsp.action['source.organizeImports'],
              desc = 'Organize Imports',
            },
            {
              '<leader>cM',
              LazyVim.lsp.action['source.addMissingImports.ts'],
              desc = 'Add missing imports',
            },
            {
              '<leader>cu',
              LazyVim.lsp.action['source.removeUnused.ts'],
              desc = 'Remove unused imports',
            },
            {
              '<leader>cD',
              LazyVim.lsp.action['source.fixAll.ts'],
              desc = 'Fix all diagnostics',
            },
            {
              '<leader>cV',
              function()
                LazyVim.lsp.execute { command = 'typescript.selectTypeScriptVersion' }
              end,
              desc = 'Select TS workspace version',
            },
          },
        },
      },

      --    setup = {
      --      tsgo = function(_, opts)
      --        -- Disable some vtsls features in favor of tsgo.
      --        -- https://neovim.discourse.group/t/how-to-config-multiple-lsp-for-document-hover/3093/2
      --        Snacks.util.lsp.on({ name = "vtsls" }, function(_, client)
      --          client.server_capabilities.hoverProvider = false
      --        end)
      --        -- end workaround
      --      end,
    },
  },

  -- project-wide TypeScript type-checking using the TypeScript compiler (tsc). It displays the
  -- type-checking results in a quickfix list and provides visual notifications about the progress
  -- and completion of type-checking.
  --
  -- Command is :TSC
  {
    'dmmulroy/tsc.nvim',
    -- https://github.com/dmmulroy/tsc.nvim?tab=readme-ov-file#configuration
    opts = {
      auto_start_watch_mode = true,
      bin_name = 'tsgo',
      use_trouble_qflist = true,
      use_diagnostics = false, -- default
    },
  },
}

--[[

{
  codeActionProvider = {
    codeActionKinds = { "", "quickfix", "refactor.rewrite", "refactor.extract" },
    resolveProvider = false
  },
  codeLensProvider = {
    resolveProvider = true
  },
  colorProvider = true,
  completionProvider = {
    resolveProvider = true,
    triggerCharacters = { "\t", "\n", ".", ":", "(", "'", '"', "[", ",", "#", "*", "@", "|", "=", "-", "{", " ", "+", "?" }
  },
  definitionProvider = true,
  documentFormattingProvider = true,
  documentHighlightProvider = true,
  documentOnTypeFormattingProvider = {
    firstTriggerCharacter = "\n"
  },
  documentRangeFormattingProvider = true,
  documentSymbolProvider = true,
  executeCommandProvider = {
    commands = { "lua.removeSpace", "lua.solve", "lua.jsonToLua", "lua.setConfig", "lua.getConfig", "lua.autoRequire" }
  },
  foldingRangeProvider = true,
  hoverProvider = true,
  implementationProvider = true,
  inlayHintProvider = {
    resolveProvider = true
  },
  offsetEncoding = "utf-16",
  referencesProvider = true,
  renameProvider = {
    prepareProvider = true
  },
  semanticTokensProvider = {
    full = true,
    legend = {
      tokenModifiers = { "declaration", "definition", "readonly", "static", "deprecated", "abstract", "async", "modification", "documentation", "defaultLibrary", "global" },
      tokenTypes = { "namespace", "type", "class", "enum", "interface", "struct", "typeParameter", "parameter", "variable", "property", "enumMember", "event", "function", "method", "macro", "keyword", "modifier", "comment", "string", "number", "regexp", "operator", "decorator" }
    },
    range = true
  },
  signatureHelpProvider = {
    triggerCharacters = { "(", "," }
  },
  textDocumentSync = {
    change = 2,
    openClose = true,
    save = {
      includeText = false
    }
  },
  typeDefinitionProvider = true,
  workspace = {
    fileOperations = {
      didRename = {
        filters = { {
            pattern = {
              glob = "/home/aron/AA/Skel/neovim/.config/nvim/**",
              options = {
                ignoreCase = true
              }
            }
          } }
      }
    },
    workspaceFolders = {
      changeNotifications = true,
      supported = true
    }
  },
  workspaceSymbolProvider = true
}

--]]
