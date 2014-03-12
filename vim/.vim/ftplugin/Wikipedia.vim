" Taken from http://en.wikipedia.org/wiki/Wikipedia:Text_editor_support#Vim
setlocal fileencoding=utf-8
setlocal linebreak
setlocal matchpairs+=<:>
setlocal textwidth=0
noremap <buffer> k gk
noremap <buffer> j gj
noremap <buffer> <Up> gk
noremap <buffer> <Down> gj
noremap <buffer> 0 g0
noremap <buffer> ^ g^
noremap <buffer> $ g$
inoremap <buffer> <Up> <C-O>gk
inoremap <buffer> <Down> <C-O>gj
