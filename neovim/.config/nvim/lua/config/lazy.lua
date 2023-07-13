local lazypath = vim.env.LAZY or vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  spec = {
    -- add LazyVim and import its plugins
    { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
    -- import any extras modules here
    { import = 'lazyvim.plugins.extras.formatting.prettier' },
    { import = 'lazyvim.plugins.extras.lang.typescript' },
    { import = 'lazyvim.plugins.extras.lang.json' },
    -- import/override with your plugins
    { import = 'plugins' },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins
    -- will load during startup. If you know what you're doing, you can set this
    -- to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin
    -- that support versioning, have outdated releases, which may break your
    -- Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- use latest stable for plugins that support semver
  },
  install = { colorscheme = { 'tokyonight', 'habamax' } },
  checker = { enabled = false }, -- don't automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some neovim-provided rtp plugins
      disabled_plugins = {
        'gzip',
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
}
