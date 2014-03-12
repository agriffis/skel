" $Id: ri.vim 3990 2010-03-29 11:58:39Z agriffis $
" Plugin for using ri (Ruby Interactive) from Vim
" Copyright 2005-2007 Aron Griffis <agriffis n01se.net>
" Released under the GNU GPL v2

let g:rititle = 'Ruby Interactive'
let g:ricmd = 'ri'

function! Ri(str)
  " str is what we're looking for
  let s:str_esc = escape(a:str, '!<>:#%\ ')

  " riname is the new name of the buffer
  let s:riname = g:rititle.' -- '.a:str
  let s:riname_esc = escape(s:riname, '!<>:#%\ ')

  " Find a suitable window or make one.
  " Count through the windows since bufwinnr() fails when there's >1 match.
  " Prefer the current window if it's an RI window.
  let s:wnum = winnr()
  let s:bnum = winbufnr(s:wnum)
  if bufname(s:bnum) !~ g:rititle
    let s:wnum = 0
    while 1
      let s:bnum = winbufnr(s:wnum)
      if s:bnum == -1 || bufname(s:bnum) =~ g:rititle
        break
      end
      let s:wnum = s:wnum + 1
    endwhile
  endif
  if s:bnum != -1
    " Found an existing RI window; switch to it.
    exe s:wnum.'wincmd w'
  else
    " Make a wide enough window (just like :help)
    if winwidth('%') > 79 || winwidth('%') == winwidth(-1)
      exe 'silent above 10new'
    else
      exe 'silent top 10new'
    endif
  endif

  " Set buffer options similar to :help windows
  setl bufhidden=delete buftype=nofile noswapfile nobuflisted

  " Name this buffer
  exe 'silent file '.s:riname_esc

  " Replace existing content with RI output
  silent %delete _      " _ is the black-hole register
  exe 'silent 0r!' . g:ricmd . ' ' . s:str_esc
  normal gg
endfunction

command! -nargs=1 Ri :call Ri("<args>")

" Suggested mapping
"nnoremap <F2> :call Ri(expand('<cword>'))<cr>
"vnoremap <F2> "ry:call Ri(@r)<cr>
