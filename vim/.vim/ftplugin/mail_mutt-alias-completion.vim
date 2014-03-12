" mutt alias completion for vim via ctrl-x ctrl-u
" $Id: mail_mutt-alias-completion.vim 2550 2007-06-21 16:01:30Z agriffis $
"
" Copyright 2007 Aron Griffis <agriffis n01se.net>
" Released under the GNU GPL v2

" This plugin requires 7.0 features
if v:version < 700
  finish
endif

function! MuttAliasDict(f)
  let aliases = {}
  if filereadable(a:f)
    exe "new " . a:f
    silent vglobal/^alias\s\+\w\+\s[^']\+$/d
    silent %s/^alias\s\+\(\w\+\)\s\+\(.*\)$/let aliases['\1'] = '\2'/
    let zreg = @z
    silent %yank z
    q!
    exec @z
    let @z = zreg
  endif
  return aliases
endfunction

" Completion function for aliases
function! CompleteMuttAlias(findstart, base)
  if !exists("g:mutt_aliases")
    let g:mutt_aliases = {}
    if exists("g:mutt_aliasfiles")
      for af in g:mutt_aliasfiles
        call extend(g:mutt_aliases, MuttAliasDict(af))
      endfor
    endif
  endif
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\w'
      let start -= 1
    endwhile
    return start
  else
    " find aliases matching with a:base
    for k in sort(keys(filter(copy(g:mutt_aliases), 'v:key =~ "^" . a:base')))
      call complete_add({'abbr': k, 'word': g:mutt_aliases[k]})
      if complete_check() | break | endif
    endfor
    return []
  endif
endfunction

setl completefunc=CompleteMuttAlias
