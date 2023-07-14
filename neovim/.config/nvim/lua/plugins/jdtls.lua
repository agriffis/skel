return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'mfussenegger/nvim-jdtls' },
    opts = {
      setup = {
        -- Override the default jdtls server startup to use nvim-jdtls.
        ['jdtls'] = function()
          -- The lspconfig configuration for jdtls contains two useful items:
          -- 1. The list of filetypes on which to match.
          -- 2. Custom method for finding the root for a java project.
          local lsp_config = require('lspconfig.server_configurations.jdtls').default_config
          local find_java_project_root = lsp_config.root_dir
          local filetypes = lsp_config.filetypes

          -- Attach jdtls for the proper filetypes (i.e. java). Existing server will be reused if
          -- the root_dir matches.
          vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('MyJdtls', { clear = true }),
            pattern = filetypes,
            callback = function()
              local fname = vim.api.nvim_buf_get_name(0)
              local root_dir = find_java_project_root(fname)
              local project_name = root_dir and vim.fs.basename(root_dir)
              local cmd = { 'jdtls' }
              if project_name then
                local jdtls_cache_dir =
                  vim.fs.joinpath(vim.fn.stdpath('cache'), 'jdtls', project_name)
                vim.list_extend(cmd, {
                  '-configuration',
                  vim.fs.joinpath(jdtls_cache_dir, 'config'),
                  '-data',
                  vim.fs.joinpath(jdtls_cache_dir, 'workspace'),
                })
              end
              require('jdtls').start_or_attach {
                cmd = cmd,
                root_dir = root_dir,
              }
            end,
          })
          return true -- avoid duplicate servers
        end,
      },
    },
  },
}
