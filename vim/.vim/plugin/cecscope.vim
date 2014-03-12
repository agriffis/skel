" cecscope.vim:
"  Author: Charles E. Campbell, Jr.
"  Date:   Feb 07, 2006
"  Version: 2
"  Usage:  :CS[!]  [cdefgist]
"          :CSL[!] [cdefgist]
"          :CSS[!] [cdefgist]
"          :CSH     (gives help)
"          :CSR
" ---------------------------------------------------------------------

" ---------------------------------------------------------------------
" Load Once: {{{1
if !has("cscope") || &cp || exists("g:loaded_cecscope") || v:version < 700
 finish
endif
let g:loaded_cecscope= "v2"

" ---------------------------------------------------------------------
" Public Interface: {{{1
com!       -nargs=* CS  call s:Cscope(<bang>0,<f-args>) 
com!       -nargs=? CSH call s:CscopeHelp(<q-args>)
com! -bang -nargs=* CSL call s:Cscope(4+<bang>0,<f-args>) 
com! -bang -nargs=* CSS call s:Cscope(2+<bang>0,<f-args>) 

" ---------------------------------------------------------------------
"  Functions: {{{1

" ---------------------------------------------------------------------
" Cscope: {{{2
"   Usage: :CS[ls][!]  [sgctefid]
" !: use vertical split
"
" -----
" style
" -----
"  s    (symbol)   find all references to the token under cursor
"  g    (global)   find global definition(s) of the token under cursor
"  c    (calls)    find all calls to the function name under cursor
"  t    (text)     find all instances of the text under cursor
"  e    (egrep)    egrep search for the word under cursor
"  f    (file)     open the filename under cursor
"  i    (includes) find files that include the filename under cursor
"  d    (called)   find functions that function under cursor calls
fun! s:Cscope(mode,...)
"  call Dfunc("Cscope(mode=".a:mode.") a:0=".a:0)
  if a:0 >= 1
   let style= a:1
"   call Decho("style=".style)
  endif
  if !&cscopetag
   " use cscope and ctags for ctrl-], :ta, etc
   " check cscope for symbol definitions before using ctags
   set cscopetag csto=0

   if !executable("cscope")
    echohl Error | echoerr "can't execute cscope!" | echohl None
"    call Dret("Cscope : can't execute cscope")
    return
   endif

   " show message whenver any cscope database added
   set cscopeverbose
  endif

  " decide if cs/scs and vertical/horizontal
  if a:mode == 0
   let mode= "cs"
  elseif a:mode == 1
   let a:mode= "vert cs"
  elseif a:mode == 2
   let mode= "scs"
  elseif a:mode == 3
   let mode= "vert scs"
  elseif a:mode == 4
   let mode= "silent cs"
   redir! > cscope.qf
  elseif a:mode == 5
   " restore previous efm
   if exists("b:cscope_efm")
    let &efm= b:cscope_efm
    unlet b:cscope_efm
   endif
"   call Dret("Cscope")
   return
  else
   echohl Error | echoerr "(Cscope) mode=".a:mode." not supported" | echohl None
"   call Dret("Cscope")
   return
  endif

  if a:0 == 2
   let word= a:2
  elseif style =~ '[fi]'
   let word= expand("<cfile>")
  else
   let word= expand("<cword>")
  endif

  if style == 'f'
"   call Decho("exe ".mode." find f ".word)
   exe mode." find f ".word
  elseif style == 'i'
"   call Decho("exe ".mode." find i ^".word."$")
   exe mode." find i ^".word."$"
  else
"   call Decho("exe ".mode." find ".style." ".word)
   exe mode." find ".style." ".word
  endif

  if a:mode == 4
   redir END
   if !exists("b:cscope_efm")
    let b:cscope_efm= &efm
    setlocal efm=%C\ \ \ \ \ \ \ \ \ \ \ \ \ %m
    setlocal efm+=%I\ %#%\\d%\\+\ %#%l\ %#%f\ %m
    setlocal efm+=%-GChoice\ number\ %.%#
    setlocal efm+=%-G%.%#line\ \ filename\ /\ context\ /\ line
    setlocal efm+=%-G%.%#Cscope\ tag:\ %.%#
    setlocal efm+=%-G
   endif
   lg cscope.qf
   silent! lope 5
   if has("menu") && has("gui_running") && &go =~ 'm'
    exe 'silent! unmenu '.g:DrChipTopLvlMenu.'Cscope.Restore\ Error\ Format'
    exe 'menu '.g:DrChipTopLvlMenu.'Cscope.Restore\ Error\ Format	:CSL!'."<cr>"
   endif
  endif
  if has("folding")
   silent! norm! zMzxz.
  else
   norm! z.
  endif
"  call Dret("Cscope")
endfun

" ---------------------------------------------------------------------
" CscopeHelp: {{{2
fun! s:CscopeHelp(...)
"  call Dfunc("CscopeHelp() a:0=".a:0)
  if a:0 == 0 || a:1 == ""
   echo "CS     [cdefgist]   : cscope"
   echo "CSL[!] [cdefgist]   : locallist style (! restores efm)"
   echo "CSS[!] [cdefgist]   : split window and use cscope (!=vertical split)"
   echo "CSR                 : reset/rebuild cscope database"
   let styles="!cdefgist"
   while styles != ""
"   	call Decho("styles<".styles.">")
   	call s:CscopeHelp(strpart(styles,0,1))
	let styles= strpart(styles,1)
   endwhile
"   call Dret("CscopeHelp : all")
   return
  elseif a:1 == '!' | echo "!            split vertically"
  elseif a:1 == 'c' | echo "c (calls)    find functions calling function under cursor"
  elseif a:1 == 'd' | echo "d (called)   find functions called by function under cursor"
  elseif a:1 == 'e' | echo "e (egrep)    egrep search for the word under cursor"
  elseif a:1 == 'f' | echo "f (file)     open the file named under cursor"
  elseif a:1 == 'g' | echo "g (global)   find global definition(s) of word under cursor"
  elseif a:1 == 'i' | echo "i (includes) find files that #include file named under cursor"
  elseif a:1 == 's' | echo "s (symbol)   find all references to the word under cursor"
  elseif a:1 == 't' | echo "t (text)     find all instances of the word under cursor"
  else              | echo a:1." not supported"
  endif

"  call Dret("CscopeHelp : on <".a:1.">")
endfun

" ---------------------------------------------------------------------
" Modelines: {{{1
" vim: fdm=marker
