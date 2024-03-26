return {
  'mfussenegger/nvim-jdtls',
  opts = {
    jdtls = {
      handlers = {
        ['language/status'] = function(_, result)
          -- print(result)
        end,
        ['$/progress'] = function(_, result, ctx)
          -- disable progress updates.
        end,
      },
    },
  },
}
