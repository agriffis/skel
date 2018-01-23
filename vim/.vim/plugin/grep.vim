" $Id: grep.vim 4671 2012-05-01 23:44:11Z aron $
" Vim plugin for full project search with output to quickfix window.
"
" Copyright 2010-2017 Aron Griffis <aron@arongriffis.com>
" Released under the GNU GPL v3

if exists('g:greploaded')
  finish
endif
let g:greploaded = 1

function! GrepAdd(patt)
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
  let l:grepargs = ['-e', a:patt]
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
  let @/ = a:patt  " for hlsearch in quickfix
  setlocal hlsearch
  redraw! " external grep seems to mess up the screen

  " Restore cwd and remove our temporary autocmd
  cd -
  augroup! grep_quickfix
endfunction
command! -nargs=1 GrepAdd :silent call GrepAdd(<f-args>)

function! Grep(...)
  call inputsave()
  let l:patt = a:0 ? a:1 : input('Pattern: ')
  call inputrestore()
  if ! empty(l:patt)
    call setqflist([])
    call GrepAdd(l:patt)
  endif
endfunction
command! -nargs=? Grep :call Grep(<f-args>)
nnoremap <silent> ,g :call Grep(expand('<cword>'))<cr>
vnoremap <silent> ,g "ry:call Grep(@r)<cr>

" Compat with spacevim
command! -nargs=? Ag :call Grep(<f-args>)

" Enable numbering and nowrap in the quickfix list
augroup number_quickfix
  autocmd!
  autocmd BufReadPost quickfix setl number nowrap
augroup END
