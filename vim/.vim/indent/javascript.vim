" Vim indent file
" Language:	Javascript
" Author:       Aron Griffis <aron@arongriffis.com>
" Last Change:	2012-02-12

" Only load one indent script per buffer
if exists('b:did_indent')
  finish
endif

let b:did_indent = 1

setlocal indentexpr=GetJsIndent(v:lnum)
setlocal indentkeys=0},0),0],o,O

if !exists('g:js_indent_wip')
  let g:js_indent_wip = 0
endif

function! GetJsIndent(lnum)
  if g:js_indent_wip
    python reload(javascript)
  endif
  return PyEval('javascript.get_js_indent('.a:lnum.')')
endfunction

" Utility function that's missing from the vim-python interface:
" Evaluate an expression in Python and return the value.
" This version only works for very simple return values, but
" the concept could be easily extended.
function! PyEval(pycode)
  exec 'python _pyeval = ' . a:pycode
  python import vim; vim.command('let l:pyeval = %r' % _pyeval)
  return l:pyeval
endfunction

" Import javascript.py into the long-running python interpreter so it's
" available when GetJsIndent is called.
let s:scriptdir = expand("<sfile>:h:p")
python import sys, vim
python sys.path.insert(0, vim.eval('s:scriptdir'))
python import javascript
