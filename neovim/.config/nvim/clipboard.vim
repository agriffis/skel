" clipboard.vim
"
" Written in 2003-2020 by Aron Griffis <aron@arongriffis.com>
"
" To the extent possible under law, the author(s) have dedicated all copyright
" and related and neighboring rights to this software to the public domain
" worldwide. This software is distributed without any warranty.
"
" CC0 Public Domain Dedication at
" http://creativecommons.org/publicdomain/zero/1.0/
"═══════════════════════════════════════════════════════════════════════════════

" Given a dictionary, apply the content as environment variables. Returns
" a sparse dictionary with the values prior to modification. Unfortunately
" Vim doesn't distinguish environment variables that are empty from those
" that aren't set, so variables that didn't exist previously will be
" returned as the empty string. For symmetry, especially for calling from
" WithEnv, values that are set by this function to the empty string will
" instead be removed from the environment.
function! SetEnv(env)
  let old = {}
  for [name, value] in items(a:env)
    let old[name] = eval('$' . name)
    if empty(value)
      exe 'unlet $' . name
    else
      exe 'let $' . name . ' = value'
    endif
  endfor
  return old
endfunction

" Given a dictionary and a function, return a new function that wraps the
" original function with the environment variables specified in env.
function! WithEnv(env, fun)
  function! WrappedFun(...) closure
    let old = SetEnv(a:env)
    try
      return call(a:fun, a:000)
    finally
      call SetEnv(old)
    endtry
  endfunction
  return funcref('WrappedFun')
endfunction

function! TryClipboardCmd(cmd, ...) abort
  let argv = split(a:cmd, " ")
  let out = systemlist(argv, (a:0 ? a:1 : ['']), 1)
  if v:shell_error == 0
    return out
  endif
endfunction

let s:regtype_sum = expand('~/.vim/clipboard-regtype.sum')
let s:regtype_txt = expand('~/.vim/clipboard-regtype.txt')

function! ClipboardCopy(lines, regtype)
  let sum = TryClipboardCmd('sum', a:lines)
  call writefile(sum, s:regtype_sum, 'S')
  call writefile([a:regtype], s:regtype_txt, 'S')
  return TryClipboardCmd('clipboard-provider copy', a:lines)
endfunction

function! ClipboardPaste()
  let lines = TryClipboardCmd('clipboard-provider paste')
  if type(lines) == type([])
    let regtype = 'V'
    if filereadable(s:regtype_sum) && filereadable(s:regtype_txt)
      let actual = TryClipboardCmd('sum', lines)
      let expected = readfile(s:regtype_sum)
      if actual == expected
        let regtype = readfile(s:regtype_txt)[0]
      endif
    endif
    return [lines, regtype]
  endif
endfunction

let g:clipboard = {
      \ 'copy': {
      \     '+': function('ClipboardCopy'),
      \     '*': WithEnv({'COPY_PROVIDERS': 'tmux'}, function('ClipboardCopy')),
      \ },
      \ 'paste': {
      \     '+': function('ClipboardPaste'),
      \     '*': WithEnv({'PASTE_PROVIDERS': 'tmux'}, function('ClipboardPaste')),
      \ }}

" Lower y yank to/from * by default (tmux only, not system)
set clipboard=unnamed

" Upper Y yank to system clipboard
nnoremap YY "+yy
nnoremap Y "+y
vnoremap Y "+y
