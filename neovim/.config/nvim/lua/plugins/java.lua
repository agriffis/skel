return {
  'mfussenegger/nvim-jdtls',
  opts = function(_, opts)
    opts.jdtls = function(jdtls)
      jdtls.handlers = {
        ['language/status'] = function(_, result)
          -- print(result)
        end,
        ['$/progress'] = function(_, result, ctx)
          -- disable progress updates.
        end,
      }
      -- https://github.com/eclipse-jdtls/eclipse.jdt.ls/discussions/2952
      -- table.insert(jdtls.cmd, '--jvm-arg=-Djava.compile.nullAnalysis.mode=automatic')
    end

    local _, formatter_config = next(vim.fs.find({ 'updated-formatter.xml' }, {}))

    opts.settings = {
      java = {
        -- https://github.com/mfussenegger/nvim-jdtls?tab=readme-ov-file#configuration-verbose
        -- https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
        -- https://github.com/LazyVim/LazyVim/discussions/2992
        autobuild = { enabled = false },
        format = formatter_config and {
          enabled = true,
          settings = {
            url = formatter_config,
            profile = 'dgd (Tizra)',
          },
        } or {
          enabled = false,
        },
        compile = {
          nullAnalysis = {
            mode = 'automatic',
            nonnull = 'org.eclipse.jdt.annotation.NonNull',
            nullable = 'org.eclipse.jdt.annotation.Nullable',
            nonnullbydefault = 'org.eclipse.jdt.annotation.NullableByDefault',
          },
        },
        -- seen in examples, not sure what these do
        --eclipse = { downloadSources = true },
        --maven = { downloadSources = true },
      },
    }
  end,
}
