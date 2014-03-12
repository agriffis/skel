" Repl interaction support through screen, based on
" Jonathan Palardy's slime.vim available from
" http://technotales.wordpress.com/2007/10/03/like-slime-for-vim/
"
" Copyright 2009, 2011 Aron Griffis <aron@arongriffis.com>
" Released under the GNU GPL v2

if exists("g:loaded_screenrepl")
 finish
endif
let g:loaded_screenrepl = "v1"

function! s:shquote(s)
  return "'" . substitute(a:s, "'", "'\\\\''", 'g') . "'"
endfunction

function! s:lastline(s)
  return substitute(a:s, '.*\n\%\(.\)\@=', '', '')
endfunction

function! s:tweak(s)
  if &ft == 'python'
    let l:s = a:s
    " kill intermediate newlines because they cause the interpreter
    " to assume the current block is finished.
    let l:s = substitute(l:s, '\n\%\([ \t]*\n\)*\%\([ \t]\)\@=', '\n', 'g')
    " if the last line starts with whitespace and ends with newline,
    " append an additional newline to finish the block.
    if s:lastline(l:s) =~ '^[ \t].*\n'
      let l:s .= "\n"
    endif
    return l:s
  endif
  return a:s
endfunction

function! s:screen(cmd)
  call system('screen'.
        \ ' -S '.s:shquote(b:screenrepl_session).
        \ ' -p '.s:shquote(b:screenrepl_window).
        \ ' '.a:cmd)
  return v:shell_error
endfunction

function! ScreenRepl_Send(text)
  if !exists("b:screenrepl_session") || !exists("b:screenrepl_window")
    if ScreenRepl_Vars() != 0
      " error or user cancelled
      return
    endif
  end
  let l:tmp = tempname()
  let l:text = s:tweak(a:text)
  let l:binary = l:text[-1:] == "\n" ? '' : 'b'
  call writefile(split(l:text, "\n"), l:tmp, l:binary)
  if s:screen('-X readreg r '.s:shquote(l:tmp)) ||
        \ s:screen('-X paste r')
    " probably the screen session has disappeared.
    " kill the var so the user can call back
    unlet b:screenrepl_session
    echoerr "screen stuff failed, call back to try again"
  endif
  call delete(l:tmp)
endfunction

function! ScreenRepl_Sessions(A,L,P)
  return system('screen -ls | awk '.s:shquote('/[Aa]ttached/ {print $1}'))
endfunction

function! ScreenRepl_Vars()
  let l:sessions = split(ScreenRepl_Sessions('','',0), "\n")
  if len(l:sessions) == 0
    echoerr "can't find any running screen sessions"
    return 1
  endif

  " if the session has gone away, reset b:screenrepl_session
  if exists('b:screenrepl_session')
    if index(l:sessions, b:screenrepl_session) < 0
      unlet b:screenrepl_session
    end
  end

  " default to the current screen session or look for one
  if !exists("b:screenrepl_session") || !exists("b:screenrepl_window")
    if exists('$STY')
      let b:screenrepl_session = $STY
      let b:screenrepl_window = "1"
    else
      let b:screenrepl_session = (len(l:sessions) == 1) ? l:sessions[0] : ""
      let b:screenrepl_window = "0"
    endif
  endif

  " ask the user
  let b:screenrepl_session = input("session name: ", b:screenrepl_session,
        \ "custom,ScreenRepl_Sessions")
  if len(b:screenrepl_session) == 0 | return 2 | endif

  let b:screenrepl_window = input("window name: ", b:screenrepl_window)
  if len(b:screenrepl_window) == 0 | return 3 | endif
  
  " configure the screen session
  call s:screen('-X msgwait 0')

  return 0 " success (we hope)
endfunction

vnoremap <C-c><C-c> "ry :call ScreenRepl_Send(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>
nmap <C-c>v :call ScreenRepl_Vars()<CR>
