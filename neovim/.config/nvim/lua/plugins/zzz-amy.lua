if os.getenv('USER') == 'aron' then
  return {}
end

return {
  -- Disable markdown rendering by default.
  -- Toggle with space-u-m
  {
    'MeanderingProgrammer/render-markdown.nvim',
    config = {
      enabled = false,
    },
  },

  -- Disable AI.
  {
    'folke/sidekick.nvim',
    config = {
      nes = { enabled = false },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    enabled = false,
  },

  -- Disable completions (aaa-main.lua)
  {
    'saghen/blink.cmp',
    enabled = false,
  },

  -- Disable auto pairs (pairs.lua)
  {
    'windwp/nvim-autopairs',
    enabled = false,
  },
  {
    'nvim-mini/mini.pairs',
    enabled = false,
  },
}
