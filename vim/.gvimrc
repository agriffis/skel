" .gvimrc
"
" Written in 2003-2016 by Aron Griffis <aron@arongriffis.com>
"
" To the extent possible under law, the author(s) have dedicated all copyright
" and related and neighboring rights to this software to the public domain
" worldwide. This software is distributed without any warranty.
"
" CC0 Public Domain Dedication at
" http://creativecommons.org/publicdomain/zero/1.0/
"======================================================================

" Don't do any GUI settings if not running X
if $DISPLAY != ''
  " Pre-GUI settings
  set columns=80 lines=30	" don't inherit geometry from parent term
  set guioptions-=r		" no right scrollbar
  set guioptions-=l             " no left scrollbar
  set guioptions-=R
  set guioptions-=L
  set guioptions-=T             " no toolbar
  set guioptions-=m             " no menubar
  set guifont=Monospace\ 8
  set guicursor=n-v-c:block-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,sm:block-Cursor,a:blinkwait1500-blinkoff500-blinkon1000
  set mousehide                 " hide the mouse pointer while typing
  set mousemodel=popup	        " right mouse button pops up a menu in the GUI
  if &foldmethod == 'diff'
    set columns=165             " attempt to set geometry
  endif
endif

" vim:set sw=2:
