" .vimrc
"
" Written in 2003-2017 by Aron Griffis <aron@arongriffis.com>
"
" To the extent possible under law, the author(s) have dedicated all copyright
" and related and neighboring rights to this software to the public domain
" worldwide. This software is distributed without any warranty.
"
" CC0 Public Domain Dedication at
" http://creativecommons.org/publicdomain/zero/1.0/
"======================================================================

" Keep this at the top of the file
set nocompatible

" General Settings
set autowrite           " write before a make
set backspace=2         " allow backspacing over everything in insert mode
if v:version >= 603 || (v:version == 602 && has('patch481'))
    set backupcopy+=breakhardlink " good for working on git/merc/etc. repos
endif
if has('unnamedplus')   " especially for tmux and/or xclip integration
  set clipboard=unnamedplus
endif
set cscopetag           " search cscope on ctrl-] and :tag
set encoding=utf-8      " unicode me, baby
set hidden              " don't unload buffer when it is abandoned
set history=100         " keep 100 lines of command line history
set laststatus=2        " always show a status line (with the current filename)
set listchars=tab:»·,trail:·    " how to display some special chars
set modeline modelines=5 " security peskurity
set nojoinspaces        " two spaces after a period is for old fogeys
set paragraphs=         " otherwise NROFF macros screw up CSS
set pastetoggle=<F10>
set report=0            " threshold for reporting nr. of lines changed
set ruler               " show the cursor position all the time
set shortmess+=at       " list of flags, reduce length of messages
set showcmd             " show (partial) command in status line
set showmode            " message on status line to show current mode
set showmatch           " briefly jump to matching bracket
set nowarn              " don't warn for shell command when buffer changed
set updatetime=2000
set wildmode=longest,list,full
set nowrap

" Tabs and Indents
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
set textwidth=75        " by default, although plugins or autocmds can modify

" Search and completion settings
set complete-=t         " don't search tags files by default
set complete-=i         " don't search included files -- takes too long
set ignorecase          " "foo" matches "Foo", etc
set infercase           " adjust the case of the match with ctrl-p/ctrl-n
set smartcase           " ignorecase only when the pattern is all lower
set nohlsearch          " by default, don't highlight matches after they're found

" Windowing settings
set splitright splitbelow
set equalalways         " keep windows equal when splitting (default)
set eadirection=both    " ver/hor/both - where does equalalways apply
set fillchars+=vert:│
set winheight=6         " height of current window
set winwidth=75         " width of current window

" Terminal settings
set vb t_vb=            " shut off bell entirely; see also .gvimrc

" Set the map leader to SPC, especially for spacevim
let mapleader=' '
let maplocalleader=' m'

if !has('nvim') && exists(':packadd')
  packadd! matchit
endif

" vim-plug
call plug#begin('~/.vim/plugged')

let g:spacevim_enabled_layers = [
\ 'core/buffers',
\ 'core/buffers/move',
\ 'core/files',
\ 'core/projects',
\ 'core/quit',
\ 'core/root',
\ 'core/search-symbol',
\ 'core/toggles',
\ 'core/toggles/colors',
\ 'core/toggles/highlight',
\ 'core/windows',
\ 'syntax-checking',
\ ]
Plug 'ctjhoa/spacevim'

Plug 'editorconfig/editorconfig-vim'
Plug 'godlygeek/tabular'

Plug 'vim-airline/vim-airline'
let g:airline_powerline_fonts = 1
let g:airline#extensions#syntastic#enabled = 1

Plug 'ctrlpvim/ctrlp.vim'
if executable('rg')
  let g:ctrlp_user_command = 'rg "" -l --color=never -- %s'
  let g:ctrlp_use_caching = 0
endif
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_root_markers = ['.project', '.topdir']

Plug 'scrooloose/nerdtree'

Plug 'leshill/vim-json'
Plug 'mxw/vim-jsx'
let g:jsx_ext_required = 0
" Plug 'jelera/vim-javascript-syntax'
Plug 'pangloss/vim-javascript'

Plug 'mitermayer/vim-prettier'
let g:prettier#config#semi = 'false'
let g:prettier#config#single_quote = 'true'
let g:prettier#config#bracket_spacing = 'false'
let g:prettier#config#jsx_bracket_same_line = 'false'
let g:prettier#config#trailing_comma = 'es5'

" consider https://github.com/python-mode/python-mode instead
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'tmhedberg/SimpylFold'

" https://juxt.pro/blog/posts/vim-1.html
" http://blog.venanti.us/clojure-vim/
let g:sexp_insert_after_wrap = 0
let g:sexp_enable_insert_mode_mappings = 1
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
Plug 'guns/vim-sexp'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-classpath'

Plug 'venantius/vim-cljfmt'
let g:clj_fmt_autosave = 0

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

Plug 'andreshazard/vim-freemarker' 

Plug 'posva/vim-vue'

" colorschemes
Plug 'rakr/vim-one'
Plug 'nanotech/jellybeans.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'reedes/vim-colors-pencil'

call plug#end()

" shell is bash
let g:is_bash=1

" clojure syntax config
let g:clj_highlight_builtins=1

" Syntax and filetypes
if has("syntax")
  syntax on
endif
filetype plugin indent on

" Use .vim/bak for backups
if ! isdirectory($HOME."/.vim/bak") && exists("*system")
  call system("mkdir -p $HOME/.vim/bak")
endif
if isdirectory($HOME."/.vim/bak")
  set backup
  set backupdir=~/.vim/bak,.
endif

" Use .vim/swap for swapfiles
if ! isdirectory($HOME."/.vim/swap") && exists("*system")
  call system("mkdir -p $HOME/.vim/swap")
endif
if isdirectory($HOME."/.vim/swap")
  set directory=~/.vim/swap,.
endif

" Use .vim for viminfo; directory will be made above
if isdirectory($HOME."/.vim")
  if has("viminfo")
    set viminfo='50,s100,n~/.vim/viminfo
  endif
  let $CVIMSYN='~/.vim/'
endif

" Command line editing, emacs style (See ":help <>")
cnoremap <C-A> <Home>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>
cnoremap <ESC>b <S-Left>
cnoremap <ESC>f <S-Right>
cnoremap <ESC><C-H> <C-W>
cnoremap %/ <C-R>=expand("%:p:h")."/"<CR>

" Toggle list mode
map ,L :set list!<CR>

" Toggle cursorcolumn
map ,C :set cursorcolumn!<CR>

" Reformat current paragraph
nmap Q }{gq}
vmap Q gq 

" Add support for html tidy
map ,t  :%!tidy -q --indent auto --output-xhtml yes<CR>
map ,T  :%!tidy -q --indent auto -xml<CR>
map ,tc :%!tidy -q --clean --indent auto -xml<CR>

" Tab mappings
noremap <silent> <C-N> :tabn<CR>
noremap <silent> <C-P> :tabN<CR>

" Certain Python modules rely on sys.real_prefix and will fail to import if
" it doesn't exist. Monkey-patch the sys module if sys.real_prefix doesn't
" exist...
if has('python')
  function FixPythonSysRealPrefix()
    python << EOT
import os, sys
if not hasattr(sys, 'real_prefix'):
  from distutils.sysconfig import get_python_lib
  sys.real_prefix = os.path.dirname(get_python_lib())
EOT
  endfunction
  call FixPythonSysRealPrefix()
endif

"================================= TERMINAL ================================
function! EnableBracketedPaste()
  " Enable bracketed paste everywhere except Linux console.
  " This would happen automatically on local terms, even with mosh using
  " TERM=xterm*, but doesn't happen automatically in tmux with
  " TERM=screen*. Setting it manually works fine though.
  if ! has("gui_running") && &term != 'linux' && &t_BE == ''
    let &t_BE = "\e[?2004h"  " enable
    let &t_BD = "\e[?2004l"  " disable
    let &t_PS = "\e[200~"    " start
    let &t_PE = "\e[201~"    " end
  endif
endfunction

" call immediately, isn't effective after TermResponse
call EnableBracketedPaste()

function! SetXTermColors()
  if &term =~ '^xterm' && &t_Co <= 16
    set t_Co=16
    if exists('v:termresponse')
      if match(v:termresponse, '^\[>[01];[0-9]\+;') == 0
        let l:termtype = matchstr(v:termresponse, '[01]', 3)
        let l:termpatch = matchstr(v:termresponse, '[0-9]\+', 5)
        if l:termtype == 1 && l:termpatch >= 1600
          " don't know exactly when 256-color support was introduced
          " to gnome-terminal, but at least this version and later has it.
          set t_Co=256
        endif
      endif
    endif
  endif
endfunction

if ! has("gui_running") && has("termresponse")
  augroup ag_terminal
    autocmd!
    autocmd TermResponse * call SetXTermColors()
  augroup END
endif

"================================== COLORS =================================
let g:jellybeans_background_color = ''
let g:jellybeans_background_color_256 = 'NONE'

function! TryTheme(theme, ...)
  let l:background = a:0 ? a:1 : ''
  if a:theme == 'solarized'
    " force dark bg to prevent double toggle with term scheme
    let l:background = 'dark'
  endif
  if exists('g:colors_name') && g:colors_name == a:theme &&
      \ empty(l:background) || &background == l:background
    return 1
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

function! LoadTheme()
  let l:background_file = expand('~/.vim/background')
  let l:theme_file = expand('~/.vim/theme')
  let l:background = filereadable(l:background_file) ?
                   \ readfile(l:background_file)[0] : &background
  let l:theme = filereadable(l:theme_file) ?
              \ readfile(l:theme_file)[0] : 'default'
  if l:background == &background &&
      \ exists('g:colors_name') && l:theme == g:colors_name
    return 0
  endif
  " echom l:theme . " " . l:background
  call TryTheme(l:theme, l:background)
endfunction

colorscheme default  " ensure g:colors_name is set
call LoadTheme()

if has("timers")
  function! LoadThemeTimer(timer)
    call LoadTheme()
  endfunction
  let theme_timer = timer_start(1000, 'LoadThemeTimer', {'repeat': -1})
else
  " http://vim.wikia.com/wiki/Timer_to_execute_commands_periodically
  function! LoadThemeTimer()
    call LoadTheme()
    call feedkeys("f\e")
  endfunction
  autocmd CursorHold * call LoadThemeTimer()
endif

"==================================== C ====================================
" Default options for C files
function! LoadTypeC()
  setlocal formatoptions-=tc " don't wrap text or comments automatically
  setlocal comments=s1:/*,mb:*,ex:*/,://

  let b:c_gnu=1                 " highlight gcc specific items
  let b:c_space_errors=1        " highlight trailing w/s and spaces before tab
  let b:c_no_curly_error=1      " don't highlight {} inside ()
  if &filetype == 'c'
    let b:c_syntax_for_h=1
  endif

  " Check for apparent shiftwidth=8; my default is 4
  let l:foundbrace = v:version >= 700 ?
        \ search('{\s*$', 'cnw', 1000) : search('{\s*$', 'cnw')
  if l:foundbrace != 0
    if match(getline(l:foundbrace+1), '^ *\t\|^ \{8\}') > -1
      setlocal shiftwidth=8
    endif
  endif

  if has("cindent")
    setlocal cindent cinoptions+=(0,u0,t0,l1
  endif

  if has("perl")
    " Line up continuations on long #defines
    vnoremap ,D :perldo s/(.*?)\s*\\*$/$1.(' 'x(79-length $1)).'\\'/e<CR>
  endif

  " Add support for various types of cscope searches based on the current word
  if has("cscope")
    noremap ,cc :cs find c <C-R>=expand("<cword>")<CR><CR>
    noremap ,cd :cs find d <C-R>=expand("<cword>")<CR><CR>
    noremap ,ce :cs find e <C-R>=expand("<cword>")<CR><CR>
    noremap ,cf :cs find f <C-R>=expand("<cword>")<CR><CR>
    noremap ,cg :cs find g <C-R>=expand("<cword>")<CR><CR>
    noremap ,ci :cs find i <C-R>=expand("<cword>")<CR><CR>
    noremap ,cs :cs find s <C-R>=expand("<cword>")<CR><CR>
    noremap ,ct :cs find t <C-R>=expand("<cword>")<CR><CR>
  endif
endfunction

augroup ag_c
  autocmd!
  autocmd FileType c,cpp call LoadTypeC()
augroup END

"================================== Python =================================
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

augroup ag_python
  autocmd!
  autocmd FileType python call LoadTypePython()
augroup END

"=================================== XML ===================================
function! LoadTypeXML()
  set shiftwidth=4 expandtab
  runtime scripts/closetag.vim
  inoremap <C-/> <C-R>=GetCloseTag()<CR>
  syntax cluster xmlRegionHook add=SpellErrors,SpellCorrected
endfunction

augroup ag_xml
  autocmd!
  autocmd FileType html,xml,xslt,htmldjango call LoadTypeXML()
augroup END

"=================================== CSS ===================================
function! LoadTypeCSS()
  set shiftwidth=4
endfunction

augroup ag_css
  autocmd!
  autocmd FileType css call LoadTypeCSS()
augroup END

"================================= Markdown ================================
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'clojure', 'sql']
let g:markdown_minlines = 3000

"================================= GENERAL =================================
" Detect settings of file being edited and change ours to match
function! DetectSettings()
  " First check for tabs vs spaces
  let l:tabre = '^\t\|^\( \{8}\)'
  let l:foundtab = v:version >= 700 ?
        \ search(l:tabre, 'cnpw', 1000) : search(l:tabre, 'cnpw')
  if l:foundtab == 1
    setlocal noexpandtab
  elseif l:foundtab == 2
    setlocal expandtab
  endif

  " placeholder to respond to emacs-style file format tags
  "--EMACS--
endfunction

augroup ag_general
  autocmd!

  " detect settings of file being edited and change ours to match
  autocmd BufReadPost  *      call DetectSettings()

  " When editing a file, always jump to the last cursor position.
  " This duplicates an autocmd provided by fedora, so clear that.
  augroup fedora!
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line ("'\"") <= line("$") |
        \   exe "normal! g'\"" |
        \ endif

  " Load specific settings for various filetypes
  autocmd FileType     help     map <buffer> <tab> /\|[^\|]\+\|<CR>
  autocmd FileType     dokuwiki AlignCtrl =-l+ | \^

  " for crontab -e
  autocmd BufWritePre  */tmp/* set backupcopy=yes
  autocmd BufWritePost */tmp/* set backupcopy=auto

  " other programming settings
  "autocmd FileType sh,perl,python,ruby set hlsearch
  autocmd FileType vim,ruby set shiftwidth=2 formatoptions-=tc
  autocmd FileType perl set formatoptions-=tc
  autocmd FileType clojure setlocal lisp
  autocmd FileType coffee setlocal shiftwidth=2
  autocmd BufReadPost bookmarks*.html set nowrap
augroup END

augroup filetypedetect
  " don't use :setfiletype because we need to override previous detection
  autocmd BufReadPost,BufNewFile *.md setlocal ft=markdown
  autocmd BufReadPost,BufNewFile *.wsgi setlocal ft=python
  autocmd BufNewFile,BufReadPost *.coffee setlocal ft=coffee
  autocmd BufNewFile,BufReadPost Vagrantfile* setlocal ft=ruby
  autocmd BufNewFile,BufReadPost *.overrides,*.variables setlocal ft=less
  autocmd BufNewFile,BufReadPost *.ftl setlocal ft=freemarker
augroup END

" Don't load VCSCommand plugin if it is not supported
if v:version < 700
  let g:VCSCommandDisableAll = 1
endif

" Load plugins now to prevent conflict with those that modify &bin
runtime! plugin/*.vim

if filereadable(expand("~/.vimrc.mine"))
  source ~/.vimrc.mine
endif

" vim:set shiftwidth=2:
