" .vimrc
"
" Written in 2003-2020 by Aron Griffis <aron@arongriffis.com>
"
" To the extent possible under law, the author(s) have dedicated all copyright
" and related and neighboring rights to this software to the public domain
" worldwide. This software is distributed without any warranty.
"
" CC0 Public Domain Dedication at
" http://creativecommons.org/publicdomain/zero/1.0/
"═══════════════════════════════════════════════════════════════════════════════

" First {{{
"═══════════════════════════════════════════════════════════════════════════════
" Stuff that needs to happen before other stuff.

set nocompatible

" Given a dictionary, apply the content as environment variables. Returns
" a sparse dictionary with the values prior to modification. Unfortunately
" Vim doesn't distinguish environment variables that are empty from those
" that aren't set, so variables that didn't exist previously will be
" returned as the empty string. For symmetry, especially for calling from
" WithEnv, values that are set by this function to the empty string will
" instead be removed from the environment.
function! SetEnv(env)
  let old = {}
  for [name, value] in items(a:env)
    let old[name] = eval('$' . name)
    if empty(value)
      exe 'unlet $' . name
    else
      exe 'let $' . name . ' = value'
    endif
  endfor
  return old
endfunction

" Given a dictionary and a function, return a new function that wraps the
" original function with the environment variables specified in env.
function! WithEnv(env, fun)
  function! WrappedFun(...) closure
    let old = SetEnv(a:env)
    try
      return call(a:fun, a:000)
    finally
      call SetEnv(old)
    endtry
  endfunction
  return funcref('WrappedFun')
endfunction

function! TryClipboardCmd(cmd, ...) abort
  let argv = split(a:cmd, " ")
  let out = systemlist(argv, (a:0 ? a:1 : ['']), 1)
  if v:shell_error == 0
    return out
  endif
endfunction

let s:regtype_sum = expand('~/.vim/clipboard-regtype.sum')
let s:regtype_txt = expand('~/.vim/clipboard-regtype.txt')

function! ClipboardCopy(lines, regtype)
  let sum = TryClipboardCmd('sum', a:lines)
  call writefile(sum, s:regtype_sum, 'S')
  call writefile([a:regtype], s:regtype_txt, 'S')
  return TryClipboardCmd('clipboard-provider copy', a:lines)
endfunction

function! ClipboardPaste()
  let lines = TryClipboardCmd('clipboard-provider paste')
  if type(lines) == type([])
    let regtype = 'V'
    if filereadable(s:regtype_sum) && filereadable(s:regtype_txt)
      let actual = TryClipboardCmd('sum', lines)
      let expected = readfile(s:regtype_sum)
      if actual == expected
        let regtype = readfile(s:regtype_txt)[0]
      endif
    endif
    return [lines, regtype]
  endif
endfunction

"}}}

"═══════════════════════════════════════════════════════════════════════════════
" Settings {{{
"═══════════════════════════════════════════════════════════════════════════════

" General Settings {{{
set autowrite           " write before a make
set backspace=2         " allow backspacing over everything in insert mode
set backupcopy=yes      " best for inotify
let g:clipboard = {
      \ 'copy': {
      \     '+': function('ClipboardCopy'),
      \     '*': WithEnv({'COPY_PROVIDERS': 'tmux'}, function('ClipboardCopy')),
      \ },
      \ 'paste': {
      \     '+': function('ClipboardPaste'),
      \     '*': WithEnv({'PASTE_PROVIDERS': 'tmux'}, function('ClipboardPaste')),
      \ }}
set clipboard=unnamed   " to/from * by default (tmux only, not system)
set cscopetag           " search cscope on ctrl-] and :tag
set encoding=utf-8      " unicode me, baby
set hidden              " don't unload buffer when it is abandoned
set history=100         " keep 100 lines of command line history
set nojoinspaces        " two spaces after a period is for old fogeys
set laststatus=2        " always show a status line (with the current filename)
set listchars=tab:»·,trail:·    " how to display some special chars
set modeline modelines=5 " security peskurity
set paragraphs=         " otherwise NROFF macros screw up CSS
set pastetoggle=<F10>
set report=0            " threshold for reporting nr. of lines changed
set ruler               " show the cursor position all the time
set showcmd             " show (partial) command in status line
set showmode            " message on status line to show current mode
set showmatch           " briefly jump to matching bracket
set nowarn              " don't warn for shell command when buffer changed
set updatetime=2000
set wildmode=longest,list,full
set nowrap

" Use .vim/swap for swapfiles
if ! isdirectory($HOME."/.vim/swap") && exists("*system")
  call system("mkdir -p $HOME/.vim/swap")
endif
if isdirectory($HOME."/.vim/swap")
  set directory=~/.vim/swap,.
endif

" Use .vim/info and .vim/shada for state, but keep it fast by omitting shada
" options that cause lots of file/directory stats
if exists('&shadafile')
  set shada=!,'10,f0,h,s100
  let &shadafile = expand('~/.vim/shada')
endif
"}}}

" Tabs and Indents {{{
set autoindent
set comments=b:#,b:##,n:>,fb:-,fb:*
set expandtab           " default but see autocmds
" formatoptions are in the order presented in fo-table
"   a and w are left out because we set them in muttrc for format=flowed
set formatoptions+=t    " auto-wrap using textwidth (not comments)
set formatoptions+=c    " auto-wrap comments too
set formatoptions+=r    " continue the comment header automatically on <CR>
set formatoptions-=o    " don't insert comment leader with 'o' or 'O'
set formatoptions+=q    " allow formatting of comments with gq
"set formatoptions-=w   " double-carriage-return indicates paragraph
"set formatoptions-=a   " don't reformat automatically
set formatoptions+=n    " recognize numbered lists when autoindenting
set formatoptions+=2    " use second line of paragraph when autoindenting
set formatoptions-=v    " don't worry about vi compatiblity
set formatoptions-=b    " don't worry about vi compatiblity
set formatoptions+=l    " don't break long lines in insert mode
set formatoptions+=1    " don't break lines after one-letter words, if possible
set shiftround          " round indent < and > to multiple of shiftwidth
set shiftwidth=4        " but see override in c_linux-kernel.vim
set smarttab            " use shiftwidth when inserting <Tab>
set tabstop=8           " number of spaces that <Tab> in file uses
set textwidth=80        " by default, although plugins or autocmds can modify
"}}}

" Search and completion settings {{{
set complete-=t         " don't search tags files by default
set complete-=i         " don't search included files -- takes too long
set ignorecase          " "foo" matches "Foo", etc
set infercase           " adjust the case of the match with ctrl-p/ctrl-n
set smartcase           " ignorecase only when the pattern is all lower
set nohlsearch          " by default, don't highlight matches after they're found
set grepprg=rg\ --hidden\ --line-number\ --smart-case\ --sort-files
"}}}

" Windowing settings {{{
set splitright splitbelow
set equalalways         " keep windows equal when splitting (default)
set eadirection=both    " ver/hor/both - where does equalalways apply
set fillchars=vert:╎
set winwidth=40         " width of current window
"}}}

" Terminal settings {{{
set vb t_vb=            " shut off bell entirely; see also .gvimrc

if has('nvim') && exists('&termguicolors')
  set termguicolors
endif

" Enable bracketed paste everywhere. This would happen automatically on
" local terms, even with mosh using TERM=xterm*, but doesn't happen
" automatically in tmux with TERM=screen*. Setting it manually works fine.
if ! has("gui_running") && exists('&t_BE') && &t_BE == ''
  let &t_BE = "\e[?2004h"  " enable
  let &t_BD = "\e[?2004l"  " disable
  let &t_PS = "\e[200~"    " start
  let &t_PE = "\e[201~"    " end
endif
"}}}

" Set the map leaders to SPC and SPC-m similar to Spacemacs.
" These must be set before referring to <leader> in maps
let mapleader=' '
let maplocalleader=' m'
"}}}

"═══════════════════════════════════════════════════════════════════════════════
" Plugins {{{
"═══════════════════════════════════════════════════════════════════════════════

augroup user  " captures all autocmds in plugins section
autocmd!

if !has('nvim') && exists(':packadd')
  packadd! matchit
endif

" vim-plug collects a list of plugins with :Plug, then sets runtimepath and
" loads them all in order at plug#end
call plug#begin('~/.vim/plugged')

"───────────────────────────────────────────────────────────────────────────────
" Global plugins {{{
"───────────────────────────────────────────────────────────────────────────────
Plug 'markonm/traces.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
"Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
"if $USER == 'aron'
"  Plug 'cohama/lexima.vim'
"endif

" Provides projectroot#guess()
"Plug 'dbakker/vim-projectroot'
"let g:rootmarkers = ['.project', '.git', '.hg', '.svn', '.bzr', '_darcs', 'build.xml']

Plug 'airblade/vim-rooter'
let g:rooter_patterns = ['.git', '.project', '.hg', '.bzr', '.svn', 'package.json']
let g:rooter_silent_chdir = 1

" This is the official editorconfig plugin. There is also an alternative
" sgur/vim-editorconfig which used to be preferable because it was pure VimL
" whereas the official plugin required Python. Now the official plugin doesn't
" require Python, and it provides an API for fetching domain-specific keys, see
" :help editorconfig-advanced
Plug 'editorconfig/editorconfig-vim'
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
let g:EditorConfig_max_line_indicator = 'none'

function! EditorConfigAutoformatHook(config)
  if has_key(a:config, 'autoformat') && exists(':AutoFormatBuffer')
    " configure google/codefmt to format automatically on save
    exec 'AutoFormatBuffer' a:config['autoformat']
  endif
  return 0 " success
endfunction
autocmd User PlugConfig call editorconfig#AddNewHook(function('EditorConfigAutoformatHook'))

Plug 'junegunn/vim-easy-align'
xmap ga <Plug>(EasyAlign)

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_symbols = {}
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.keymap = 'Keymap:'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.modified = '+'
let g:airline_symbols.paste = 'PASTE'
let g:airline_symbols.readonly = ''
let g:airline_symbols.space = ' '
let g:airline_symbols.spell = 'SPELL'
let g:airline_symbols.whitespace = ''

Plug 'scrooloose/nerdtree'
nnoremap <Leader>tN :NERDTreeToggle<CR>
Plug 'unkiwii/vim-nerdtree-sync'
let g:nerdtree_sync_cursorline = 1
" Plug 'Xuyuanp/nerdtree-git-plugin'

let g:spacevim_enabled_layers = [
\ 'core/buffers',
\ 'core/buffers/move',
\ 'core/quit',
\ 'core/root',
\ 'core/toggles',
\ 'core/toggles/colors',
\ 'core/toggles/highlight',
\ 'core/windows',
\ 'syntax-checking',
\ ]
Plug 'ctjhoa/spacevim'

if v:true
  if $USER == 'aron'
    set number signcolumn=number
  else
    lua vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
  endif
  Plug 'neovim/nvim-lspconfig'
  function s:setup_nvim_lsp_mappings()
    nnoremap <buffer> <silent> gA    <cmd>lua vim.lsp.buf.code_action()<CR>
    "nnoremap <buffer> <silent> gD   <cmd>lua vim.lsp.buf.declaration()<CR>
    nnoremap <buffer> <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
    nnoremap <buffer> <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
    nnoremap <buffer> <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>
    nnoremap <buffer> <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
    nnoremap <buffer> <silent> gt    <cmd>lua vim.lsp.buf.type_definition()<CR>
    nnoremap <buffer> <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
    nnoremap <buffer> <silent> gR    <cmd>lua vim.lsp.buf.rename()<CR>
    nnoremap <buffer> <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
    nnoremap <buffer> <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
    setl omnifunc=v:lua.vim.lsp.omnifunc
    setl completeopt-=preview
  endfunction
  if executable('css-languageserver')
    autocmd User PlugConfig lua require'lspconfig'.cssls.setup{}
    autocmd User PlugConfig
          \ autocmd FileType css,less,scss call s:setup_nvim_lsp_mappings()
  endif
  " doesn't work because of unreadable files in source dir (server directory)
" if executable('/home/aron/src/java-language-server/dist/lang_server_linux.sh')
"   autocmd User PlugConfig lua require'lspconfig'.java_language_server.setup{cmd='/home/aron/src/java-language-server/dist/lang_server_linux.sh'}
"   autocmd User PlugConfig
"         \ autocmd FileType java call s:setup_nvim_lsp_mappings()
" elseif executable('jdtls')
  if executable('jdtls')
    autocmd User PlugConfig lua require'lspconfig'.jdtls.setup{cmd={'jdtls'}}
    autocmd User PlugConfig
          \ autocmd FileType java call s:setup_nvim_lsp_mappings()
  endif
  if executable('typescript-language-server')
    autocmd User PlugConfig lua require'lspconfig'.tsserver.setup{}
    autocmd User PlugConfig
          \ autocmd FileType javascript,javascriptreact,typescript,typescriptreact call s:setup_nvim_lsp_mappings()
  endif
  if executable('vls')
    autocmd User PlugConfig lua require'lspconfig'.vuels.setup{}
    autocmd User PlugConfig
          \ autocmd FileType vue call s:setup_nvim_lsp_mappings()
  endif
else
  Plug 'prabirshrestha/async.vim'
  Plug 'prabirshrestha/vim-lsp'
  Plug 'mattn/vim-lsp-settings'
  let g:lsp_diagnostics_enabled = 0
  " Signs only take effect if diagnostics (above) and signcolumn (below) are
  " enabled.
  let g:lsp_signs_error = {'text': '✗'}
  let g:lsp_signs_warning = {'text': '‼'}

  function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=no
    "if $USER == 'aron' | setlocal signcolumn=yes | endif
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <localleader>rr <plug>(lsp-rename)
    nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <Plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
  endfunction
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()

  autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'jdtls',
        \ 'cmd': {server_info->['jdtls']},
        \ 'allowlist': ['java'],
        \ })
endif

Plug 'Shougo/context_filetype.vim'

if 1
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'

  function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
  endfunction

  let g:fzf_action = {
        \ 'ctrl-q': function('s:build_quickfix_list'),
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-x': 'split',
        \ 'ctrl-v': 'vsplit',
        \ }

  let g:fzf_colors = {
        \ 'fg':      ['fg', 'Normal'],
        \ 'bg':      ['bg', 'Normal'],
        \ 'hl':      ['fg', 'Comment'],
        \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
        \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
        \ 'hl+':     ['fg', 'Statement'],
        \ 'info':    ['fg', 'PreProc'],
        \ 'border':  ['fg', 'Ignore'],
        \ 'prompt':  ['fg', 'Conditional'],
        \ 'pointer': ['fg', 'Exception'],
        \ 'marker':  ['fg', 'Keyword'],
        \ 'spinner': ['fg', 'Label'],
        \ 'header':  ['fg', 'Comment'],
        \ }

  let g:fzf_history_dir = '~/.vim/fzf-history'

  function! ProjectRg(query, fullscreen)
    let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case --hidden -- %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    " We used to pass 'dir': projectroot#guess() here, but since vim-rooter
    " always changes directory for us, the current working dir is fine.
    let spec = {
          \ 'dir': getcwd(),
          \ 'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command],
          \ }
    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
  endfunction

  " We used to pass 'dir': projectroot#guess() here, but since vim-rooter
  " always changes directory for us, the current working dir is fine.
  command! -bang ProjectFiles call fzf#vim#files(getcwd(), fzf#vim#with_preview(), <bang>0)
  command! -bang -nargs=* ProjectRg call ProjectRg(<q-args>, <bang>0)

  nnoremap <leader>ff :FZF <C-R>=expand("%:p:h")<CR><CR>
  nnoremap <leader>fh :History<CR>
  nnoremap <leader>pf :ProjectFiles<CR>
  nnoremap <c-p>      :ProjectFiles<CR>
  nnoremap <leader>fg :GFiles?<CR>
  nnoremap <leader>sP :ProjectRg <C-R>=expand("<cword>")<CR><CR>
  nnoremap <leader>*  :ProjectRg <C-R>=expand("<cword>")<CR><CR>
  nnoremap <leader>sp :ProjectRg<CR>
  nnoremap <leader>/  :ProjectRg<CR>
  nnoremap <leader>bb :Buffers<CR>

  nnoremap <leader>sr :%s/\<<C-R>=expand("<cword>")<cr>\>//g<left><left>

elseif 0
  Plug 'Shougo/denite.nvim'
  Plug 'Shougo/neomru.vim'
  let g:neomru#do_validate=0

  function! ConfigDenite()
    "call denite#custom#map('insert', '<Up>', '<denite:move_to_previous_line>', 'noremap')
    "call denite#custom#map('insert', '<Down>', '<denite:move_to_next_line>', 'noremap')
    if executable('rg')
      call denite#custom#filter('matcher/clap', 'clap_path', expand('~/.vim/plugged/vim-clap'))
      "call denite#custom#source('file/rec', 'matchers', ['matcher/clap'])
      "call denite#custom#source('file/rec', 'sorters', ['sorter/sublime'])
      call denite#custom#var('file/rec', 'command', ['rg', '--files'])
      call denite#custom#var('grep', 'command', ['rg'])
      call denite#custom#var('grep', 'default_opts', ['--vimgrep', '--no-heading', '--smart-case', '--sort-files'])
      call denite#custom#var('grep', 'recursive_opts', [])
      call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
      call denite#custom#var('grep', 'separator', ['--'])
      call denite#custom#var('grep', 'final_opts', [])
      call denite#custom#source('grep', 'sorters', [])  " use rg-provided sort
    endif

    nnoremap <leader>bb :Denite -start-filter buffer<CR>
    nnoremap <leader>ff :DeniteBufferDir -start-filter file<CR>
    nnoremap <leader>fm :Denite -start-filter file_mru<CR>
    nnoremap <leader>pf :Denite -start-filter file/rec:`projectroot#guess()`<CR>
    nnoremap <c-p>      :Denite -start-filter file/rec:`projectroot#guess()`<CR>
    nnoremap <leader>sP :DeniteCursorWord -start-filter grep:`projectroot#guess()`::!<CR>
    nnoremap <leader>*  :DeniteCursorWord -start-filter grep:`projectroot#guess()`::!<CR>
    nnoremap <leader>sp :Denite -start-filter grep:`projectroot#guess()`::!<CR>
    nnoremap <leader>/  :Denite -start-filter grep:`projectroot#guess()`::!<CR>
    nnoremap <leader>sl :Denite -start-filter -resume<CR>

    function! s:denite_bindings() abort
      nnoremap <silent><buffer><expr> <CR>    denite#do_map('do_action')
      nnoremap <silent><buffer><expr> d       denite#do_map('do_action', 'delete')
      nnoremap <silent><buffer><expr> p       denite#do_map('do_action', 'preview')
      nnoremap <silent><buffer><expr> q       denite#do_map('quit')
      nnoremap <silent><buffer><expr> <C-c>   denite#do_map('quit')
      nnoremap <silent><buffer><expr> i       denite#do_map('open_filter_buffer')
      nnoremap <silent><buffer><expr> <Space> denite#do_map('toggle_select').'j'
    endfunction
    autocmd FileType denite call s:denite_bindings()

    function! s:denite_filter_bindings() abort
      inoremap <silent><buffer><expr> <C-o>  <Plug>(denite_filter_quit)
      inoremap <silent><buffer><expr> <CR>   denite#do_map('do_action')
      inoremap <silent><buffer><expr> <C-c>  denite#do_map('quit')
      inoremap <silent><buffer><expr> <Up>   denite#increment_parent_cursor(-1)
      inoremap <silent><buffer><expr> <Down> denite#increment_parent_cursor(1)
      inoremap <silent><buffer><expr> <C-k>  denite#increment_parent_cursor(-1)
      inoremap <silent><buffer><expr> <C-j>  denite#increment_parent_cursor(1)
    endfunction
    autocmd FileType denite-filter call s:denite_filter_bindings()

  endfunction
  autocmd User PlugConfig call ConfigDenite()

elseif has('patch-8.1.2114') || has('nvim-0.4')
  let g:clap_stop_bottom_top = 1
  let g:clap_layout = {'relative': 'editor'}
  "let g:clap_provider_grep_opts = '--hidden'
  autocmd ColorScheme * let g:clap_theme = 'solarized_' . &background
  " autocmd ColorScheme * let g:clap_theme = 'solarized_dark'
  Plug 'liuchengxu/vim-clap', {'do': ':Clap install-binary'}
  nnoremap <Leader>fm :Clap history<CR>
  nnoremap <Leader>ff :Clap files .<CR>
  nnoremap <Leader>pf :Clap files<CR>
  nnoremap <c-p>      :Clap files<CR>
  nnoremap <Leader>fg :Clap git_diff_files<CR>
  nnoremap <Leader>sp :Clap grep<CR>
  nnoremap <Leader>/  :Clap grep<CR>
  nnoremap <Leader>sP :Clap grep ++query=<cword><CR>
  nnoremap <Leader>*  :Clap grep ++query=<cword><CR>
  nnoremap <Leader>bb :Clap buffers<CR>
endif

" Code formatting -- https://github.com/google/vim-codefmt
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
autocmd User PlugConfig call glaive#Install()
Plug 'agriffis/vim-codefmt', {'branch': 'scampersand'}
autocmd User PlugConfig Glaive codefmt plugin[mappings]

" Color schemes
Plug 'NLKNguyen/papercolor-theme'
let g:PaperColor_Theme_Options = {
      \   'theme': {
      \     'default': {
      \       'transparent_background': 1,
      \       'allow_bold': 1,
      \       'allow_italic': 1,
      \     },
      \     'default.light': {
      \       'override': {
      \         'color07': ['#000000', '16'],
      \       }
      \     }
      \   }
      \ }
Plug 'nanotech/jellybeans.vim'
let g:jellybeans_background_color = ''
let g:jellybeans_background_color_256 = 'NONE'
Plug 'rakr/vim-one'
let g:one_allow_italics = 1
Plug 'reedes/vim-colors-pencil'
Plug 'doums/darcula'
Plug 'morhetz/gruvbox'
let g:gruvbox_contrast = 'hard'
Plug 'lifepillar/vim-solarized8'
Plug 'liuchengxu/space-vim-theme'
Plug 'nelstrom/vim-mac-classic-theme'
Plug 'JaySandhu/xcode-vim'
Plug 'https://gitlab.com/protesilaos/tempus-themes-vim.git'
Plug 'chriskempson/base16-vim'
"}}}

"───────────────────────────────────────────────────────────────────────────────
" HTML {{{
"───────────────────────────────────────────────────────────────────────────────
" Assume <p> will include closing </p> and content should be indented.
" If more are needed, this should be a comma-separated list.
let g:html_indent_inctags = 'p,main'

Plug 'agriffis/vim-jinja'
Plug 'mustache/vim-mustache-handlebars'

"Plug 'agriffis/vim-freemarker'
autocmd BufNewFile,BufReadPost *.ftl set ft=ftl
"autocmd BufNewFile,BufReadPost *.ftl set ft=html

" Plug 'agriffis/vim-vue', {'branch': 'develop'}
" autocmd User PlugConfig
"       \ autocmd FileType vue let &l:cinoptions = g:javascript_cinoptions
autocmd User PlugConfig
      \ autocmd FileType vue setl comments=s:<!--,m:\ \ \ \ \ ,e:-->,s1:/*,mb:*,ex:*/,://
" autocmd User PlugConfig
"       \ autocmd FileType vue syn sync fromstart
Plug 'posva/vim-vue'

Plug 'agriffis/closetag.vim'
" The closetag.vim script is kinda broken... it requires b:unaryTagsStack
" per buffer but only sets it once, on script load.
autocmd BufNewFile,BufReadPre * let b:unaryTagsStack="area base br dd dt hr img input link meta param"
autocmd FileType javascriptreact,markdown,xml let b:unaryTagsStack=""
" Replace the default closetag maps with c-/ in insert mode only.
autocmd FileType html,javascriptreact,markdown,vue,xml inoremap <buffer> <C-/> <C-r>=GetCloseTag()<CR>

autocmd FileType xml syntax cluster xmlRegionHook add=SpellErrors,SpellCorrected

" Disable Eclim's HTML/CSS indentation which overrides html.vim
let g:EclimHtmlIndentDisabled = 1
let g:EclimCssIndentDisabled = 1

function! ReHtml(type, ...)
  let cmd = "rehtml -i" . &shiftwidth
  if a:0
    " invoked from visual mode, use gv command XXX not working
    silent exe "normal gv"
    silent exe "'<,'>!" . cmd
  else
    " a:type is line/char/block but always treat as line
    silent exe "'[,']!" . cmd
  endif
endfunction
" see :help :map-operator
autocmd FileType html nnoremap <buffer> <localleader>rf :set opfunc=ReHtml<CR>g@
autocmd FileType html vnoremap <buffer> <localleader>rf :<C-u>call ReHtml(visualmode(), 1)<CR>

" vim bundles vim-markdown (by tpope)
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'clojure', 'sql']
let g:markdown_minlines = 500

" mdx is markdown with embedded jsx
Plug 'jxnblk/vim-mdx-js'
autocmd BufNewFile,BufReadPost *.js set filetype=javascriptreact

autocmd BufNewFile,BufReadPost *.overrides,*.variables set ft=less
"}}}

"───────────────────────────────────────────────────────────────────────────────
" JavaScript {{{
"
" Lots of helpful info to get started at
" https://davidosomething.com/blog/vim-for-javascript/
"───────────────────────────────────────────────────────────────────────────────
" vim-javascript is the best available javascript indenter/hilighter.
" Note that once vim-javascript is loaded, it is automatically used by
" the built-in html.vim for <script> sections via g:html_indent_script1
Plug 'pangloss/vim-javascript'
let g:javascript_plugin_jsdoc = 1

" vim-javascript is configured with cinoptions, see
" https://github.com/pangloss/vim-javascript#indentation-specific
" This also applies to FileType vue above.
let g:javascript_cinoptions = '(0,Ws'
let g:javascript_indent_W_pat = '[^[:blank:]{[]'  " https://github.com/pangloss/vim-javascript/issues/1114
autocmd FileType javascript,javascriptreact,typescript,typescriptreact let &l:cinoptions = g:javascript_cinoptions
autocmd FileType javascript,javascriptreact,typescript,typescriptreact setl comments=s1:/*,mb:*,ex:*/,://
autocmd FileType javascript,javascriptreact,typescript,typescriptreact setl shiftwidth=2

Plug 'heavenshell/vim-jsdoc'
autocmd FileType javascript noremap <localleader>rdf $?function<CR>:noh<CR><Plug>(jsdoc)

" Disable Eclim's JS indentation which overrides vim-javascript.
let g:EclimJavascriptIndentDisabled = 1

"Plug 'ternjs/tern_for_vim'
"let g:tern#command = ['tern']
" yarn config set prefix ~/.local
" yarn global add tern
"autocmd FileType javascript noremap <localleader>gg :TernDef<CR>
"autocmd FileType javascript noremap gd :TernDef<CR>

" Configure deoplete for javascript
"Plug 'carlitux/deoplete-ternjs'
"let g:deoplete#sources#ternjs#docs = 1
"let g:deoplete#sources#ternjs#expand_word_forward = 0

" Configure codefmt to call prettier with vim settings (and leave everything
" else set by config files)
"autocmd User PlugConfig Glaive codefmt prettier_options=`{-> [
"      \ '--print-width=' . &textwidth,
"      \ '--tab-width=' . &shiftwidth,
"      \ ]}`
"autocmd User PlugConfig Glaive codefmt prettier_executable="/home/aron/src/xstyled/node_modules/.bin/prettier"
"autocmd User PlugConfig Glaive codefmt prettier_executable=`['yarn', 'prettier']`

" vim-jsx-pretty replaces the deprecated vim-jsx to augment vim-javascript
" with support for JSX indenting and highlighting.
Plug 'maxmellon/vim-jsx-pretty'

" vim-json highlights keys/values separately, conceals quotes except on the
" cursor line, and highlights errors loudly.
"Plug 'elzr/vim-json'
"let g:vim_json_syntax_conceal = 0
"autocmd FileType json,yaml setl shiftwidth=2
"}}}

"───────────────────────────────────────────────────────────────────────────────
" TOML {{{
"───────────────────────────────────────────────────────────────────────────────
Plug 'cespare/vim-toml'
"}}}

"───────────────────────────────────────────────────────────────────────────────
" Python {{{
"───────────────────────────────────────────────────────────────────────────────
Plug 'Vimjas/vim-python-pep8-indent'
" Plug 'tmhedberg/SimpylFold'

" Consider https://github.com/python-mode/python-mode
" with configuration below

" If this option is set to 1, pymode will enable the following options
" for python buffers:
"
"     setlocal complete+=t
"     setlocal formatoptions-=t
"     if v:version > 702 && !&relativenumber
"         setlocal number
"     endif
"     setlocal nowrap
"     setlocal textwidth=79
"     setlocal commentstring=#%s
"     setlocal define=^\s*\\(def\\\\|class\\)
"
let g:pymode_options = 1

" Additional pymode settings
let g:pymode_trim_whitespaces = 0
let g:pymode_folding = 1
let g:pymode_indent = 1  " PEP8
let g:pymode_lint_on_fly = 0
let g:pymode_lint_on_write = 0
let g:pymode_lint_unmodified = 0
let g:pymode_lint_ignore = "E301,E302,E261,E501"
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_autoimport = 1
let g:pymode_rope_goto_definition_cmd = 'e'

" pymode bindings
let g:pymode_rope_completion_bind = ''       " <C-Space>

" The g:pyindent settings only take effect if g:pymode_indent == 0
" http://stackoverflow.com/questions/3538785/how-to-turn-off-double-indentation-in-vim
let g:pyindent_open_paren = '&sw'
let g:pyindent_nested_paren = '&sw'
let g:pyindent_continue = '&sw'

function! LoadTypePython()
  " When working in a virtualenv, this relies on the virtualenv.vim
  " plugin to set sys.path properly.  Vim links to the system libpython
  " and doesn't know about the virtualenv path otherwise.
  if has('python')
    python import os, sys, vim
    python vim.command("setlocal path+=" + ",".join(sys.path[1:]))
  endif

  " Override g:pymode_options
  setlocal nonumber
  setlocal tabstop=8

  " Additional default settings for Python
  setlocal shiftwidth=4
  setlocal noshiftround

  " Unfold by default
  normal zR
endfunction

autocmd BufReadPost,BufNewFile *.wsgi set ft=python
autocmd FileType python nnoremap <buffer><silent> <localleader>= :silent w<CR>:silent !reformat-python "%"<CR>:silent e!<CR>
autocmd FileType python call LoadTypePython()
"}}}

"───────────────────────────────────────────────────────────────────────────────
" Ruby {{{
"───────────────────────────────────────────────────────────────────────────────
autocmd BufNewFile,BufReadPost Vagrantfile* set ft=ruby
"}}}

"───────────────────────────────────────────────────────────────────────────────
" Java, Clojure {{{
"───────────────────────────────────────────────────────────────────────────────
autocmd FileType java setlocal cindent cinoptions+=(0,u0,t0,l1 ")

Plug 'tpope/vim-classpath'

Plug 'guns/vim-sexp'
let g:sexp_insert_after_wrap = 0
Plug 'tpope/vim-sexp-mappings-for-regular-people'
function! s:my_sexp_mappings() abort
  nmap <buffer> ><  <Plug>(sexp_emit_head_element)
  nmap <buffer> <>  <Plug>(sexp_emit_tail_element)
  nmap <buffer> <<  <Plug>(sexp_capture_prev_element)
  nmap <buffer> >>  <Plug>(sexp_capture_next_element)
endfunction
autocmd User PlugConfig
      \ autocmd FileType clojure,lisp,scheme call s:my_sexp_mappings()

if 1
  Plug 'tpope/vim-fireplace'
else
  Plug 'liquidz/vim-iced', {'for': 'clojure'}
  " These don't work, not sure why
  let g:iced#nrepl#path_translation = {
          \ '/opt/agilepublisher-9/webapps/ROOT/WEB-INF/classes': '/home/aron/src/ss/clients/tizra/cubchicken/src/main/clj',
          \ '/home/agilepublisher/cubchicken/target/ROOT/WEB-INF/classes': '/home/aron/src/ss/clients/tizra/cubchicken/src/main/clj',
          \ '/home/agilepublisher/cubchicken': '/home/aron/src/ss/clients/tizra/cubchicken',
          \ }
  let g:iced#promise#timeout_ms = 8000 " default is 3000, not enuf for cubchicken
  function! s:my_iced_mappings() abort
    silent! nmap <buffer> <Leader>' <Plug>(iced_connect)
    silent! nmap <buffer> <Leader>" <Plug>(iced_jack_in)

    "" Evaluating (<Leader>e)
    "" ------------------------------------------------------------------------
    silent! nmap <buffer> <Leader>eq <Plug>(iced_interrupt)
    silent! nmap <buffer> <Leader>eQ <Plug>(iced_interrupt_all)
    silent! nmap <buffer> <Leader>ei <Plug>(iced_eval)<Plug>(sexp_inner_element)``
    silent! nmap <buffer> <Leader>ee <Plug>(iced_eval)<Plug>(sexp_outer_list)``
    silent! nmap <buffer> <Leader>et <Plug>(iced_eval_outer_top_list)
    silent! vmap <buffer> <Leader>ee <Plug>(iced_eval_visual)
    silent! nmap <buffer> <Leader>en <Plug>(iced_eval_ns)
    silent! nmap <buffer> <Leader>ep <Plug>(iced_print_last)
    silent! nmap <buffer> <Leader>eb <Plug>(iced_require)
    silent! nmap <buffer> <Leader>eB <Plug>(iced_require_all)
    silent! nmap <buffer> <Leader>eu <Plug>(iced_undef)
    silent! nmap <buffer> <Leader>eU <Plug>(iced_undef_all_in_ns)
    silent! nmap <buffer> <Leader>eM <Plug>(iced_macroexpand_outer_list)
    silent! nmap <buffer> <Leader>em <Plug>(iced_macroexpand_1_outer_list)

    "" Testing (<Leader>t)
    "" ------------------------------------------------------------------------
    silent! nmap <buffer> <Leader>tt <Plug>(iced_test_under_cursor)
    silent! nmap <buffer> <Leader>tl <Plug>(iced_test_rerun_last)
    silent! nmap <buffer> <Leader>ts <Plug>(iced_test_spec_check)
    silent! nmap <buffer> <Leader>to <Plug>(iced_test_buffer_open)
    silent! nmap <buffer> <Leader>tn <Plug>(iced_test_ns)
    silent! nmap <buffer> <Leader>tp <Plug>(iced_test_all)
    silent! nmap <buffer> <Leader>tr <Plug>(iced_test_redo)

    "" Stdout buffer (<Leader>s)
    "" ------------------------------------------------------------------------
    silent! nmap <buffer> <Leader>ss <Plug>(iced_stdout_buffer_open)
    silent! nmap <buffer> <Leader>sl <Plug>(iced_stdout_buffer_clear)
    silent! nmap <buffer> <Leader>sq <Plug>(iced_stdout_buffer_close)

    "" Refactoring (<Leader>r)
    "" ------------------------------------------------------------------------
    silent! nmap <buffer> <Leader>rcn <Plug>(iced_clean_ns)
    silent! nmap <buffer> <Leader>rca <Plug>(iced_clean_all)
    silent! nmap <buffer> <Leader>ram <Plug>(iced_add_missing)
    silent! nmap <buffer> <Leader>ran <Plug>(iced_add_ns)
    silent! nmap <buffer> <Leader>rtf <Plug>(iced_thread_first)
    silent! nmap <buffer> <Leader>rtl <Plug>(iced_thread_last)
    silent! nmap <buffer> <Leader>ref <Plug>(iced_extract_function)
    silent! nmap <buffer> <Leader>raa <Plug>(iced_add_arity)
    silent! nmap <buffer> <Leader>rml <Plug>(iced_move_to_let)

    "" Help/Document (<Leader>h)
    "" ------------------------------------------------------------------------
    silent! nmap <buffer> K <Plug>(iced_popup_document_open)
    silent! nmap <buffer> <Leader>hb <Plug>(iced_document_open)
    silent! nmap <buffer> <Leader>hu <Plug>(iced_use_case_open)
    silent! nmap <buffer> <Leader>hn <Plug>(iced_next_use_case)
    silent! nmap <buffer> <Leader>hN <Plug>(iced_prev_use_case)
    silent! nmap <buffer> <Leader>hq <Plug>(iced_document_close)
    silent! nmap <buffer> <Leader>hS <Plug>(iced_source_show)
    silent! nmap <buffer> <Leader>hs <Plug>(iced_popup_source_show)
    silent! nmap <buffer> <Leader>hc <Plug>(iced_clojuredocs_open)
    silent! nmap <buffer> <Leader>hh <Plug>(iced_command_palette)

    "" Browsing (<Leader>b)
    "" ------------------------------------------------------------------------
    silent! nmap <buffer> <Leader>bn <Plug>(iced_browse_related_namespace)
    silent! nmap <buffer> <Leader>bs <Plug>(iced_browse_spec)
    silent! nmap <buffer> <Leader>bt <Plug>(iced_browse_test_under_cursor)
    silent! nmap <buffer> <Leader>br <Plug>(iced_browse_references)
    silent! nmap <buffer> <Leader>bd <Plug>(iced_browse_dependencies)
    silent! nmap <buffer> <Leader>bvr <Plug>(iced_browse_var_references)
    silent! nmap <buffer> <Leader>bvd <Plug>(iced_browse_var_dependencies)

    "" Jumping cursor (<Leader>j)
    "" ------------------------------------------------------------------------
    silent! nmap <buffer> <C-]> <Plug>(iced_def_jump)
    silent! nmap <buffer> <Leader>jn <Plug>(iced_jump_to_next_sign)
    silent! nmap <buffer> <Leader>jN <Plug>(iced_jump_to_prev_sign)
    silent! nmap <buffer> <Leader>jl <Plug>(iced_jump_to_let)

    "" Debugging (<Leader>d)
    "" ------------------------------------------------------------------------
    silent! nmap <buffer> <Leader>dbt <Plug>(iced_browse_tapped)
    silent! nmap <buffer> <Leader>dlt <Plug>(iced_clear_tapped)

    "" Misc
    "" ------------------------------------------------------------------------
    "silent! nmap <buffer> == <Plug>(iced_format)
    "silent! nmap <buffer> =G <Plug>(iced_format_all)
    "silent! nmap <buffer> <Leader>* <Plug>(iced_grep)
    "silent! nmap <buffer> <Leader>/ :<C-u>IcedGrep<Space>
  endfunction
  autocmd User PlugConfig
        \ autocmd FileType clojure call s:my_iced_mappings()
endif

Plug 'guns/vim-clojure-static'
let g:clj_highlight_builtins=1

" Configure codefmt to zprint top-level forms with <leader>==
autocmd User PlugConfig
      \ autocmd FileType clojure nmap <buffer> <silent> <leader>== <leader>=iF

" following required for eastwood
" https://github.com/venantius/vim-eastwood/issues/8
Plug 'tpope/vim-salve'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-dispatch'

Plug 'venantius/vim-eastwood'
" https://github.com/venantius/vim-eastwood/issues/9
"let g:syntastic_clojure_checkers = ['eastwood']

"Plug 'vim-syntastic/syntastic'
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"}}}

"───────────────────────────────────────────────────────────────────────────────
" C {{{
"───────────────────────────────────────────────────────────────────────────────
function! LoadTypeC()
  setlocal formatoptions-=tc " don't wrap text or comments automatically
  setlocal comments=s1:/*,mb:*,ex:*/,://
  setlocal cindent cinoptions+=(0,u0,t0,l1 ")

  let b:c_gnu=1                 " highlight gcc specific items
  let b:c_space_errors=1        " highlight trailing w/s and spaces before tab
  let b:c_no_curly_error=1      " don't highlight {} inside ()
  if &filetype == 'c'
    let b:c_syntax_for_h=1
  endif

  " Add support for various types of cscope searches based on the current word
  if has("cscope")
    noremap <buffer> <localleader>gc :cs find c <C-R>=expand("<cword>")<CR><CR>
    noremap <buffer> <localleader>gd :cs find d <C-R>=expand("<cword>")<CR><CR>
    noremap <buffer> <localleader>ge :cs find e <C-R>=expand("<cword>")<CR><CR>
    noremap <buffer> <localleader>gf :cs find f <C-R>=expand("<cword>")<CR><CR>
    noremap <buffer> <localleader>gg :cs find g <C-R>=expand("<cword>")<CR><CR>
    noremap <buffer> <localleader>gi :cs find i <C-R>=expand("<cword>")<CR><CR>
    noremap <buffer> <localleader>gs :cs find s <C-R>=expand("<cword>")<CR><CR>
    noremap <buffer> <localleader>gt :cs find t <C-R>=expand("<cword>")<CR><CR>
  endif
endfunction

autocmd FileType c,cpp call LoadTypeC()
"}}}

"───────────────────────────────────────────────────────────────────────────────
" Shell {{{
"───────────────────────────────────────────────────────────────────────────────
let g:is_bash=1
"}}}

if has('nvim')
  Plug 'norcalli/nvim-colorizer.lua'
  autocmd User PlugConfig lua require'colorizer'.setup{'*';'!text'}
endif

call plug#end()

augroup END  " ends augroup user
doautocmd User PlugConfig
"}}}

"═══════════════════════════════════════════════════════════════════════════════
" Mappings {{{
"═══════════════════════════════════════════════════════════════════════════════

" Insert path of current file on command-line with %/
cnoremap %/ <C-R>=expand("%:p:h")."/"<CR>

" Toggle list mode (spacemacs-style binding)
nnoremap <leader>tw :set list!<CR>

" Reformat current paragraph
nmap Q }{gq}
vmap Q gq

" Copy to system clipboard
nmap YY "+yy
nmap Y "+y
vmap Y "+y

" Toggle diff mode
function! DiffToggle()
  if &diff
    diffoff
  else
    diffthis
  endif
endfunction
nmap <leader>td :call DiffToggle()<CR>

" Disable movement keys that I hit accidentally sometimes.
"inoremap <Up> <nop>
"inoremap <Down> <nop>
"inoremap <Left> <nop>
"inoremap <Right> <nop>
"inoremap <PageUp> <nop>
"inoremap <PageDown> <nop>
"inoremap <Home> <nop>
"inoremap <End> <nop>
"}}}

"═══════════════════════════════════════════════════════════════════════════════
" Colors {{{
"═══════════════════════════════════════════════════════════════════════════════

function! TryTheme(theme, background)
  let l:background = a:theme == 'solarized' ? 'dark' : a:background
  if ! empty(l:background)
    let &background = l:background
  endif
  try
    exec 'colorscheme' a:theme
  catch /^Vim\%((\a\+)\)\=:E185/
    return 0
  endtry
  if ! empty(l:background)
    let &background = l:background
  endif
  if exists('syntax_on')
    syn reset
  endif
endfunction

function! LoadTheme(from_timer)
  let l:background_file = expand('~/.vim/background')
  let l:theme_file = expand('~/.vim/theme')
  let l:background = filereadable(l:background_file) ? readfile(l:background_file)[0] : ''
  let l:theme = filereadable(l:theme_file) ? readfile(l:theme_file)[0] : 'default'
  if (a:from_timer &&
        \ (exists('g:tried_theme') && l:theme == g:tried_theme) &&
        \ (exists('g:tried_background') && l:background == g:tried_background))
    return 0
  endif
  let g:tried_theme = l:theme
  let g:tried_background = l:background
  call TryTheme(l:theme, l:background)
endfunction

call LoadTheme(0)

if has("timers")
  function! LoadThemeTimer(timer)
    call LoadTheme(1)
  endfunction
  let theme_timer = timer_start(1000, 'LoadThemeTimer', {'repeat': -1})
else
  " http://vim.wikia.com/wiki/Timer_to_execute_commands_periodically
  function! LoadThemeTimer()
    call LoadTheme(1)
    call feedkeys("f\e")
  endfunction
  autocmd CursorHold * call LoadThemeTimer()
endif
"}}}

"═══════════════════════════════════════════════════════════════════════════════
" Final {{{
"═══════════════════════════════════════════════════════════════════════════════

" When editing a file, always jump to the last cursor position.
" This duplicates an autocmd provided by fedora, so clear that.
augroup user
  augroup fedora!
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line ("'\"") <= line("$") |
        \   exe "normal! g'\"" |
        \ endif
  autocmd BufReadPost COMMIT_EDITMSG exe "normal! gg"
augroup END

" Load plugins now to prevent conflict with those that modify &bin
runtime! plugin/*.vim

if filereadable(expand("~/.vimrc.mine"))
  source ~/.vimrc.mine
endif
"}}}

" vim:set shiftwidth=2 foldmethod=marker:
