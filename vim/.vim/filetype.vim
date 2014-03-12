augroup filetypedetect

autocmd BufReadPost,BufNewFile .sawmillrc,.sawfishrc,*.jl setfiletype lisp
autocmd BufReadPost,BufNewFile *.tmpl                     setfiletype html
autocmd BufReadPost,BufNewFile *.wiki                     setfiletype Wikipedia
autocmd BufReadPost,BufNewFile *wikipedia.org.*           setfiletype Wikipedia
autocmd BufReadPost,BufNewFile hpedia.fc.hp.com.*         setfiletype Wikipedia
autocmd BufReadPost,BufNewFile hpedia.hp.com.*            setfiletype Wikipedia
autocmd BufReadPost,BufNewFile griffis1.net.*             setfiletype Wikipedia
" following should really be dokuwiki, but there's no good syntax file yet
autocmd BufReadPost,BufNewFile linux.fc.hp.com.*.txt      setfiletype dokuwiki

augroup END
