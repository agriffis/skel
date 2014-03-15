" $Id: vimrc 4892 2013-10-15 12:59:57Z aron $

" Keep this at the top of the file
set nocompatible

" General Settings
set autowrite           " write before a make
set backspace=2         " allow backspacing over everything in insert mode
if v:version >= 603 || (v:version == 602 && has('patch481'))
    set backupcopy+=breakhardlink " good for working on git/merc/etc. repos
endif
" set clipboard=autoselectml,unnamedplus
set cscopetag           " search cscope on ctrl-] and :tag
set encoding=utf-8      " unicode me, baby
set hidden              " don't unload buffer when it is abandoned
set history=100         " keep 100 lines of command line history
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
set swapsync=""         " don't call fsync() or sync(); let linux handle it
set nowarn              " don't warn for shell command when buffer changed
set wildmode=longest,list,full

" Statusline thanks to Ciaran
set laststatus=2        " always show a status line (with the current filename)
set statusline=
set statusline+=%{winnr()}:%-3.3n\           " window number:buffer number
set statusline+=%f\                          " file name
set statusline+=%h%m%r%w                     " flags
set statusline+=\[%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding},                " encoding
set statusline+=%{&fileformat}]              " file format
if filereadable(expand("$VIM/vimfiles/plugin/vimbuddy.vim"))
    set statusline+=\ %{VimBuddy()}          " vim buddy
endif
set statusline+=%=                           " right align
set statusline+=0x%-8B\                      " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset

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
set winheight=6         " height of current window
set winwidth=75         " width of current window

" Terminal settings
set vb t_vb=            " shut off bell entirely; see also .gvimrc

" The rest of this file, except for inclusion of .vimrc.mine, is subject to vim
" being compiled with +eval.  Normally this is the case, except on Gentoo when
" USE=minimal
if 1

" Enable pathogen bundles, must be before filetype etc.
call pathogen#infect()
call pathogen#helptags()

" When using the taglist plugin, don't attempt to resize the terminal
let Tlist_Inc_Winwidth=0

" Configure the CtrlP plugin
let g:ctrlp_user_command = {
  \ 'types': {
    \ 1: ['.git', 'cd %s && git ls-files'],
    \ 2: ['.hg', 'hg --cwd %s locate -I .'],
    \ },
  \ 'fallback': 'find %s -type f'
  \ }
let g:ctrlp_extensions = ['tag']
let g:ctrlp_cmd = 'CtrlPMixed'

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
    set viminfo='50,n~/.vim/viminfo
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

"================================== COLORS =================================
runtime scripts/detect_background.vim
if ! exists('g:loaded_detect_background')
  function! DetectBackground(foo)
    let g:detected_background = &background
    return g:detected_background
  endfunction
endif

" When using the inkpot colorscheme, make the background black instead of gray
let g:inkpot_black_background=1

function! TryColorscheme(scheme)
  if exists('g:colors_name') && g:colors_name == a:scheme
    return 0
  endif
  try
    exec 'colorscheme' a:scheme
    return 0
  catch /^Vim\%((\a\+)\)\=:E185/
  endtry
  return 1
endfunction

let g:dark_colorscheme = 'inkpot'
let g:light_colorscheme = 'default'

function! SetColors()
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
  if g:detected_background == 'dark' && (&term == 'builtin_gui' || &t_Co >= 88)
        \ && TryColorscheme(g:dark_colorscheme) == 0
    return
  elseif g:detected_background == 'light' 
        \ && TryColorscheme(g:light_colorscheme) == 0
    return
  endif
  call TryColorscheme('default')
endfunction

" :colorscheme default resets &background, for no apparent reason
function! RestoreBackground()
  if exists('g:colors_name') && g:colors_name == 'default' &&
        \ exists('g:detected_background') &&
        \ g:detected_background != &background
    let &background = g:detected_background
    if exists('syntax_on') | syn reset | endif
  endif
endfunction

function! ColorSetup()
  call DetectBackground(v:termresponse)
  let &background = g:detected_background
  call SetColors()
  call RestoreBackground()
endfunction

if has("gui_running") || ! has("termresponse") || &t_RV == ''
  augroup ag_setcolors
    autocmd!
    autocmd VimEnter,GUIEnter * call ColorSetup()
  augroup END
else
  augroup ag_setcolors
    autocmd!
    autocmd TermResponse * call ColorSetup()
  augroup END
endif

augroup ag_setcolors
  autocmd TermChanged * if &t_RV == '' | call ColorSetup() | endif
augroup END

if v:version >= 700
  augroup ag_setcolors
    " NOTE: This won't nest inside TermResponse, and it isn't covered by
    " autocmd-nested, so we also call RestoreBackground() explicitly from
    " ColorSetup()
    autocmd ColorScheme * call RestoreBackground()
  augroup END
endif

"=================================== MAIL ==================================
augroup ag_mail
  autocmd!
  autocmd FileType mail set textwidth=65 nohlsearch expandtab " formatoptions+=wa
augroup END

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
let g:pymode_lint_on_save = 0
let g:pymode_lint_unmodified = 0
let g:pymode_lint_ignore = "E301,E302,E261,E501"
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_completion_bind = ''
let g:pymode_rope_autoimport = 1
let g:pymode_rope_goto_definition_cmd = 'e'

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

"================================ Markdown =================================
function! LoadTypeMarkdown()
  "set number wrap linebreak nolist textwidth=0 wrapmargin=0
endfunction

augroup ag_markdown
  autocmd!
  autocmd FileType markdown,ghmarkdown call LoadTypeMarkdown()
augroup END

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
  autocmd BufReadPost,BufNewFile *.md setlocal ft=ghmarkdown
  autocmd BufReadPost,BufNewFile *.wsgi setlocal ft=python
  autocmd BufNewFile,BufReadPost *.coffee setlocal ft=coffee
  autocmd BufNewFile,BufReadPost Vagrantfile* setlocal ft=ruby
augroup END

" Don't load VCSCommand plugin if it is not supported
if v:version < 700
  let g:VCSCommandDisableAll = 1
endif

" Load plugins now to prevent conflict with those that modify &bin
runtime! plugin/*.vim

" DISABLED 05 May 2008 because this seems to conflict with the gnupg.vim plugin
" Read and write binary files
" augroup au_bin
"   autocmd!
"   autocmd BufReadPre   *.bin  let &bin=1
"   call system("which xxd &>/dev/null")
"   if shell_error == 0
"     autocmd BufReadPost  * if &bin | %!xxd
"     autocmd BufReadPost  * set ft=xxd | endif
"     autocmd BufWritePre  * if &bin | %!xxd -r
"     autocmd BufWritePre  * endif
"     autocmd BufWritePost * if &bin | %!xxd
"     autocmd BufWritePost * set nomod | endif
"   endif
" augroup END

if filereadable(expand("~/.vimrc.mine"))
  source ~/.vimrc.mine
endif

finish  " to prevent sourcing vimrc.mine twice
endif   " has("eval")

" source ~/.vimrc.mine

" vim:set shiftwidth=2:
