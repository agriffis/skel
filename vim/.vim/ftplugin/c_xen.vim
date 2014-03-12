" Xen tags/cscope/include support for vim
" $Id: c_xen.vim 2857 2007-12-12 16:44:05Z agriffis $
"
" Copyright 2007 Aron Griffis <agriffis n01se.net>
" Released under the GNU GPL v2

" Only do this when not done yet for this buffer
if exists("b:did_c_xen_ftplugin")
  finish
endif
let b:did_c_xen_ftplugin = 1

function! Xen_SetXenPath()
  if !has("modify_fname")
    return 0
  endif
  let l:fwd = expand("%:p:h")     " working directory of current file

  let l:matchmin = 0
  while 1
    let l:xen_match = matchstr(l:fwd, '^.\{-' . l:matchmin . ',\}/xen\(/\@=\|$\)')
    if !strlen(l:xen_match) 
      return 0
    endif
    if filereadable(l:xen_match . '/Rules.mk')
      let b:xen_path = l:xen_match
      break
    endif
    let l:matchmin = strlen(l:xen_match)
  endwhile

  return 1
endfunction

if Xen_SetXenPath()
  setlocal shiftwidth=4

  " set include search path
  let s:arch = system("readlink " . b:xen_path . "/include/asm 2>/dev/null")
  if shell_error == 0
    let s:arch = strpart(s:arch, 0, strlen(s:arch)-1) " snip newline
    let s:arch = substitute(s:arch, ".*asm-", "", "")
  else
    let s:arch = "ia64"
  endif
  " make xen 2>&1 | grep -m1 -o -e '-I[^[:space:]]*' 
  let &l:path = b:xen_path . "/include"
  let &l:path .= "," . b:xen_path . "/include/asm-" . s:arch
  let &l:path .= "," . b:xen_path . "/include/asm-" . s:arch . "/linux"
  let &l:path .= "," . b:xen_path . "/include/asm-" . s:arch . "/linux-xen"
  let &l:path .= "," . b:xen_path . "/include/asm-" . s:arch . "/linux-null"
  let &l:path .= "," . b:xen_path . "/s:arch/" . s:arch . "/linux"
  let &l:path .= "," . b:xen_path . "/s:arch/" . s:arch . "/linux-xen"

  " set tags path
  let &l:tags = b:xen_path . "/tags"

  " load cscope database
  if has('cscope') && filereadable(b:xen_path . "/cscope.out")
    let &l:csprg = &g:csprg . " -k"
    exe "cs add " . b:xen_path . "/cscope.out " . b:xen_path
  endif
endif
