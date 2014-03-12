let n = 0
while n <= 10
  if getline(n) =~ '^use.*tmpl;'
    " Add HTML embedding for ehmod...  HTML starts with q{\s*<
    unlet b:current_syntax
    syn include @HTMLStuff syntax/html.vim
    syn region ehmodHTML start=/q{/ end=/}/ contains=@HTMLStuff keepend
    " syn region ehmodHTML start=/q{\_\s*</ end=/}/ contains=@HTMLStuff keepend
    break
  endif
  let n = n + 1
endwhile
