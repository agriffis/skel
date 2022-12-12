local M = {}

function starts_with(s, ss)
  return string.sub(s, 1, string.len(ss)) == ss
end

function trim_prefix(s, prefix)
  if starts_with(s, prefix) then
    s = string.sub(s, string.len(prefix) + 1)
  end
  return s
end

function M.config(options)
  local my = require('my')
  local nls = require('null-ls')
  local h = require('null-ls.helpers')
  local methods = require('null-ls.methods')
  local b = nls.builtins

  -- There's a way to do this with jdtls eventually, which would be much faster:
  -- https://github.com/eclipse/eclipse.jdt.ls/pull/640
  local eclipse = {
    name = 'eclipse',
    filetypes = {'java'},
    method = {methods.internal.FORMATTING},
    condition = function(utils)
      return utils.root_has_file({'eclipse-formatter.ini'})
    end,
    generator = h.formatter_factory {
      command = function(params)
        return params.root .. '/bin/eclipse-formatter'
      end,
      args = {'--filter'},
      to_stdin = true,
      timeout = 5000, -- not working yet, https://github.com/jose-elias-alvarez/null-ls.nvim/discussions/706
    },
  }

  local zprint = {
    name = 'zprint',
    filetypes = {'clojure'},
    method = {methods.internal.FORMATTING, methods.internal.RANGE_FORMATTING},
    generator = h.generator_factory {
      command = 'zprint',
      args = function(params)
        if params.method == methods.internal.FORMATTING then
          return {}
        end
        return {string.format(
          '{:input {:range {:start %d :end %d :use-previous-!zprint? true :continue-after-!zprint-error? true}}}',
          params.range.row - 1,
          params.range.end_row - 1
        )}
      end,
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/discussions/1229
      format = 'raw',
      on_output = function(params, done)
        if params.err ~= nil and params.err ~= '' then
          local err = trim_prefix(params.err, "Failed to zprint: clojure.lang.ExceptionInfo: ")
          my.warn(err, "zprint failed")
        end
        -- zprint returns the text regardless of error
        return done({{text = params.output}})
      end,
      to_stdin = true,
      ignore_stderr = false, -- default for generator_factory
    }
  }

  _G.zprint_generator = zprint.generator

  nls.setup {
    on_attach = options.on_attach,
    save_after_format = false,
    sources = {
      b.formatting.prettier.with({command = 'proxier'}),
      b.formatting.stylua,
      eclipse,
      zprint,
    },
  }
end

return M
