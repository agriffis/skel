return {
  -- Send buffers into early retirement by automatically closing them after x minutes of inactivity.
  -- https://github.com/chrisgrieser/nvim-early-retirement?tab=readme-ov-file#configuration
  {
    'chrisgrieser/nvim-early-retirement',
    config = true,
    event = 'VeryLazy',
  },
}
