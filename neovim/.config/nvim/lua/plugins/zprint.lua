-- Use zprint for clojure formatting.

---@param style string
local function zprinter(style)
  ---@type conform.FileFormatterConfig
  return {
    meta = {
      url = 'https://github.com/kkinnear/zprint',
      description = string.format('Zprint with %s', style),
    },
    command = 'zprint',
    args = { string.format('{:style %s}', style) },
    range_args = function(self, ctx)
      return {
        string.format(
          '{:style %s :input {:range {:start %d :end %d :use-previous-!zprint? true :continue-after-!zprint-error? true}}}',
          style,
          ctx.range.start[1] - 1,
          ctx.range['end'][1] - 1
        ),
      }
    end,
  }
end

return {
  'stevearc/conform.nvim',
  opts = {
    ---@type table<string, conform.FileFormatterConfig>
    formatters = {
      zprint_respect = zprinter(':respect-nl'),
      zprint_disrespect = zprinter(':respect-nl-off'),
      zprint_indent = zprinter(':indent-only'),
    },

    formatters_by_ft = {
      -- This is the formatter that will be used by <leader>cf, gq operator, and
      -- also the = operator via keymaps.lua.
      clojure = { 'zprint' },
    },

    -- Custom opts entry, not consumed by conform. See keymaps.lua
    ---@type table<string, string[][]>
    formatters_by_ft_alt = {
      clojure = {
        -- First alt, available as <leader>=1
        -- or conform.format({opts: {formatters: {'zprint_disrespect'}}})
        { 'zprint_disrespect' },

        -- Second alt, available as <leader>=2
        -- or conform.format({opts: {formatters: {'zprint_respect'}}})
        { 'zprint_respect' },

        -- Third alt, available as <leader>=3
        -- or conform.format({opts: {formatters: {'zprint_indent'}}})
        { 'zprint_indent' },
      },
    },
  },
}
