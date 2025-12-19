local my = require('my')

return {
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      vim.list_extend(opts.inlay_hints.exclude, { 'java' })
      opts.setup = {
        jdtls = function()
          return true -- defer to nvim-jdtls to start server
        end,
      }
    end,
  },

  -- Enable debug and hot code replacement for autotest.
  -- To use this, first `make debug` and then `<space>dc` to attach the
  -- debugger, then `<space>du` to put away the debugger UI.
  {
    'mfussenegger/nvim-dap',
    opts = function()
      -- https://github.com/mfussenegger/nvim-dap/wiki/Java
      -- Attach to autotest debug host/port (currently hard-coded to 3100 in ctl.sh)
      local dap = require('dap')
      dap.configurations.java = {
        {
          type = 'java',
          request = 'attach',
          name = 'Debug (Attach) - autotest',
          hostName = 'autotest.dev.agilepublisher.com',
          port = 3100,
        },
        {
          type = 'java',
          request = 'attach',
          name = 'Debug (Attach) - systest',
          hostName = 'systest.dev11.agilepublisher.com',
          port = 3100,
        },
      }
    end,
  },

  {
    'mfussenegger/nvim-jdtls',
    opts = function(_, opts)
      -- Enable jdtls to work with unsaved code.
      -- This is passed into settings below.
      local jdtls = require('jdtls')
      local extendedClientCapabilities = jdtls.extendedClientCapabilities
      extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

      -- Override the LSP status handler to ignore uninteresting messages.
      local default_status_handler = vim.lsp.handlers['language/status']
      local function my_status_handler(err, result, ctx)
        -- print('status: ' .. vim.inspect { err, result, ctx })
        return default_status_handler(err, result, ctx)
      end

      -- Override the LSP progress handler to ignore uninteresting messages.
      local default_progress_handler = vim.lsp.handlers['$/progress']
      local progress_tracker = {}
      local function my_progress_handler(err, result, ctx)
        -- print('progress: ' .. vim.inspect { err, result, ctx })
        -- Don't report on stuff that just begins and ends successfully.
        if not err then
          if result.value.kind == 'begin' then
            return
          end
          if result.value.kind == 'report' and result.value.percentage == 0 then
            return
          end
          if result.value.kind == 'end' and not progress_tracker[result.token] then
            return
          end
        end
        if result and result.token then
          if result.value.kind == 'end' then
            progress_tracker[result.token] = nil
          else
            progress_tracker[result.token] = true
          end
        end
        return default_progress_handler(err, result, ctx)
      end

      return vim.tbl_deep_extend('force', opts, {
        jdtls = function(server)
          server.handlers = {
            ['language/status'] = my_status_handler,
            ['$/progress'] = my_progress_handler,
          }
        end,

        -- https://github.com/mfussenegger/nvim-jdtls?tab=readme-ov-file#configuration-verbose
        -- https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
        -- https://github.com/LazyVim/LazyVim/discussions/2992
        settings = {
          java = {
            -- Enable autobuild because we are using hot code replacement via
            -- the debug port. If we want to go back to the old build/restart
            -- process, then run `make dev` instead of `make debug`, and disable
            -- autobuild here.
            autobuild = { enabled = true },

            -- These are the null annotations we're using in cubchicken. We have
            -- to set these explicitly to avoid jdtls from clearing the
            -- corresponding settings in `.settings/org.eclipse.jdt.core.prefs`
            compile = {
              nullAnalysis = {
                mode = 'automatic',
                nonnull = 'org.eclipse.jdt.annotation.NonNull',
                nullable = 'org.eclipse.jdt.annotation.Nullable',
                nonnullbydefault = 'org.eclipse.jdt.annotation.NullableByDefault',
              },
            },

            -- Apply our modified extendedClientCapabilities to work with
            -- unsaved code.
            extendedClientCapabilities = extendedClientCapabilities,

            -- Not sure what all of these do, just stuff seen on the web.
            eclipse = { downloadSources = true },
            maven = { downloadSources = true },
            references = { includeDecompiledSources = true },
            signatureHelp = { enabled = true },
          },
        },
      })
    end,
  },
}
