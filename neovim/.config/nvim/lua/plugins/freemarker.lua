local dev = {
  dir = '~/src/tree-sitter-freemarker',
  dev = true,
}

local prod = {
  url = 'https://tangled.org/arongriffis.com/tree-sitter-freemarker',
}

return vim.tbl_deep_extend('force', {
  'arongriffis.com/tree-sitter-freemarker',
  build = ':TSInstall freemarker',
  opts = { extensions = { ftl = 'freemarker.html' } },
}, vim.uv.fs_stat(vim.fn.expand(dev.dir)) and dev or prod)
