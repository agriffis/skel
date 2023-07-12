local function starts_with(s, ss)
  return string.sub(s, 1, string.len(ss)) == ss
end

local function trim_prefix(s, prefix)
  if starts_with(s, prefix) then
    s = string.sub(s, string.len(prefix) + 1)
  end
  return s
end

return {
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local my = require('my')
      local h = require('null-ls.helpers')
      local methods = require('null-ls.methods')

      local zprint = {
        name = 'zprint',
        filetypes = { 'clojure' },
        method = { methods.internal.FORMATTING, methods.internal.RANGE_FORMATTING },
        generator = h.generator_factory {
          command = 'zprint',
          args = function(params)
            if params.method == methods.internal.FORMATTING then
              return {}
            end
            return {
              string.format(
                '{:input {:range {:start %d :end %d :use-previous-!zprint? true :continue-after-!zprint-error? true}}}',
                params.range.row - 1,
                params.range.end_row - 1
              ),
            }
          end,
          -- https://github.com/jose-elias-alvarez/null-ls.nvim/discussions/1229
          format = 'raw',
          on_output = function(params, done)
            if params.err ~= nil and params.err ~= '' then
              local err = trim_prefix(params.err, 'Failed to zprint: clojure.lang.ExceptionInfo: ')
              my.warn(err, 'zprint failed')
            end
            -- zprint returns the text regardless of error
            return done { { text = params.output } }
          end,
          to_stdin = true,
          ignore_stderr = false, -- default for generator_factory
        },
      }

      -- Hack to reset error state
      --_G.zprint_generator = zprint.generator
      --_G.zprint_generator._failed = false

      table.insert(opts.sources, zprint)
    end,
  },
}
