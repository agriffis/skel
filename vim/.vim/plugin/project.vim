" $Id: project.vim 4889 2013-10-15 12:57:53Z aron $
" Vim plugin for working on projects, particularly Python projects using
" a virtualenv
"
" Copyright 2010-2011 Aron Griffis <aron@arongriffis.com>
" Released under the GNU GPL v3

if exists('g:projectloaded')
  finish
endif
let g:projectloaded = 1

if ! exists('$VIRTUAL_ENV')
  finish
endif

" Use our topdir program to find the top of the project
if ! exists('g:topdir')
  let s:curdir = expand('%:p:h')
  if strlen(s:curdir) == 0
    let s:curdir = '.'
  endif
  let g:topdir = system('topdir 2>/dev/null ' . shellescape(s:curdir))
  let g:topdir = g:topdir[0:-2]  " trim the newline
  if v:shell_error != 0
    unlet g:topdir
  endif
endif

" If we didn't get anything, we're done
if ! exists('g:topdir')
  finish
endif

" Search path for gf and :find
" The double g:topdir here does breadth-first at the top level before
" depth-first starting at the second level. That means that :find urls.py
" finds the root match instead of matches inside app dirs.
exec "set path=.,".g:topdir.",".g:topdir."/*/**"

" ----------------------------------------------------------------------
" Tags: Rebuild with top-level mktags script

exec "set tags+=".g:topdir."/tags"

" ----------------------------------------------------------------------
" Grep: Full project search, provided by grep.vim

let g:grepinc = ['*.py', '*.html', '*.less', '*.css', '*.js', '*.xsd', '*.feature', '*.email']
let g:grepexc2 = ['*.min.js', 'CACHE', 'htmlcov', '_deploy*', '_static*']
let g:grepdir = g:topdir " .'/'.g:virtualenv

" ----------------------------------------------------------------------
" Filetype settings

augroup filetypedetect
  " don't use :setfiletype because we need to override previous detection
  autocmd BufReadPost,BufNewFile *.html setl ft=htmldjango
augroup END
