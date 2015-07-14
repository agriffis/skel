" $Id: grep.vim 4671 2012-05-01 23:44:11Z aron $
" Vim plugin for full project search with output to quickfix window.
"
" Copyright 2010-2012 Aron Griffis <aron@arongriffis.com>
" Released under the GNU GPL v3

if exists('g:greploaded')
  finish
endif
let g:greploaded = 1

function! GrepInit()
  if exists('g:grepargs')
    return
  endif

  " Determine whether the system grep supports GNU options
  if ! exists('g:grepgnu')
    let g:grepgnu = system('grep --help 2>&1') =~ '.*--exclude-dir=.*'
  endif

  if ! exists('g:grepinc')
    let g:grepinc = ['*']
  endif

  if ! exists('g:grepexc')
    let g:grepexc = split('_darcs .git .hg .svn .tox CVS migrations')
    let g:grepexc += split('*~ *.bak *.o *.pyc *.mo')
    if exists('g:grepexc2')
      let g:grepexc += g:grepexc2
    endif
  endif

  let g:grepargs = map(copy(g:grepinc), '"--include=".v:val')
  let g:grepargs += map(copy(g:grepexc), '"--exclude=".v:val')
  if g:grepgnu
    let g:grepargs += map(copy(g:grepexc), '"--exclude-dir=".v:val')
    let g:grepargs += ['--binary-files=without-match']
  endif
endfunction

function! GrepAdd(patt)
  call GrepInit()

  if exists('g:grepdir')
    let l:grepdir = g:grepdir
  else
    " Default to the directory of the file being editing
    let l:grepdir = expand('%:p:h')
    if strlen(l:grepdir) == 0
      let l:grepdir = '.'
    endif

    " Try to use the topdir util to find an appropriate starting place
    let l:topdir = system('topdir 2>/dev/null ' . shellescape(l:grepdir))
    let l:topdir = l:topdir[0:-2]  " trim the newline
    if v:shell_error == 0 && len(l:topdir)
      let l:grepdir = l:topdir
    endif
  endif

  " We need an absolute path so the autocmd trimming works
  let l:grepdir = fnamemodify(l:grepdir, ':p')

  " Temporary autocmd to remove the common path components from the quickfix
  " list, so it's easier to read without a superwide terminal.
  exe 'cd '.l:grepdir
  augroup grep_quickfix
  autocmd BufReadPost quickfix setl modifiable
        \ | silent exe 'silent! %s,^\./,,'
        \ | setl nomodifiable
  augroup END

  " Shell escapes, applied first:
  "   * The arguments need to be quoted to prevent globbing, preserve
  "     spaces, prevent | from being treated as a pipe, etc.
  let l:grepargs = g:grepargs + ['-r', '.', '-Ee', a:patt]
  call map(l:grepargs, 'shellescape(v:val)')  " modifies in-place
  let l:grep = 'grepadd! ' . join(l:grepargs, ' ')

  " Vim escapes, applied second (since they're stripped first):
  "   * The % and # need to be escaped to prevent vim from expanding them
  "     to current and alternate filename respectively.
  "   * The | needs to be escaped so vim doesn't interpret it as the
  "     command separator.
  "   * The \ should need to be escaped since it's the escape character --
  "     but vim is not consistent. It looks specifically for \% and \# and
  "     doesn't unescape backslashes (apparently)
  let l:grep = substitute(l:grep, '[%#|]', '\\\0', 'g')
  exe "silent ".l:grep
  botright cwindow
  redraw! " external grep seems to mess up the screen

  " Restore cwd and remove our temporary autocmd
  cd -
  augroup! grep_quickfix
endfunction
command! -nargs=1 GrepAdd :silent call GrepAdd(<f-args>)

function! Grep(patt)
  call setqflist([])
  call GrepAdd(a:patt)
endfunction
command! -nargs=1 Grep :silent call Grep(<f-args>)
nnoremap <silent> ,g :call Grep(expand('<cword>'))<cr>
vnoremap <silent> ,g "ry:call Grep(@r)<cr>

" Enable numbering and nowrap in the quickfix list
augroup number_quickfix
  autocmd!
  autocmd BufReadPost quickfix setl number nowrap
augroup END
