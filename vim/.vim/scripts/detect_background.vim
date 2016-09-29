" $Id: detect_background.vim 3219 2008-07-28 21:30:59Z agriffis $
"
" Copyright 2007 Aron Griffis <agriffis n01se.net>
" Released under the GNU GPL v2

let g:loaded_detect_background = 1

if v:version < 700
  function! DetectBackground(s)
    let g:detected_background = &background
    return g:detected_background
  endfunction
  finish
endif

function! XTermControlGetBG()
  let l:bgcolors = matchlist(system("xtermcontrol --force --get-bg <>/dev/tty"),
        \ '^rgb:\([0-9a-fA-F]\+\)/\([0-9a-fA-F]\+\)/\([0-9a-fA-F]\+\)')
  if empty(l:bgcolors)
    return &background
  else
    let l:bgavg = (str2nr(l:bgcolors[1], 16) +
          \ str2nr(l:bgcolors[2], 16) +
          \ str2nr(l:bgcolors[3], 16)) / 3
    if l:bgavg > str2nr('ffff', 16) / 2
      return 'light'
    else
      return 'dark'
    endif
  end
endfunction

function! DetectBackground(s)
  let g:detected_background = &background

  if &term =~ '^xterm'
    let l:ml = matchlist(a:s, '^\[>\([01]\);\([0-9]\+\);')
    " l:ml[1]=1 for gnome-terminal
    " l:ml[2]=115 for konsole-3.5.9
    " current version of xterm is 235
    if len(l:ml) && l:ml[1] != 1 && l:ml[2] > 200
      let g:detected_background = XTermControlGetBG()
    endif

  elseif &term =~ '^rxvt'
    let g:detected_background = XTermControlGetBG()
  endif

  return g:detected_background
endfunction
