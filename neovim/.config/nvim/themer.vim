function! TryTheme(theme, background)
  let l:background = a:theme == 'solarized' ? 'dark' : a:background
  if ! empty(l:background)
    let &background = l:background
  endif
  try
    exec 'colorscheme' a:theme
  catch /^Vim\%((\a\+)\)\=:E185/
    return 0
  endtry
  if ! empty(l:background)
    let &background = l:background
  endif
  if exists('syntax_on')
    syn reset
  endif
endfunction

let s:background_file = expand('~/.vim/background')
let s:theme_file = expand('~/.vim/theme')

function! LoadTheme(from_timer)
  let l:background = filereadable(s:background_file) ? readfile(s:background_file)[0] : ''
  let l:theme = filereadable(s:theme_file) ? readfile(s:theme_file)[0] : 'default'
  if (a:from_timer &&
        \ (exists('g:tried_theme') && l:theme == g:tried_theme) &&
        \ (exists('g:tried_background') && l:background == g:tried_background))
    return 0
  endif
  let g:tried_theme = l:theme
  let g:tried_background = l:background
  call TryTheme(l:theme, l:background)
endfunction

call LoadTheme(0)

if has("timers")
  function! LoadThemeTimer(timer)
    call LoadTheme(1)
  endfunction
  let theme_timer = timer_start(1000, 'LoadThemeTimer', {'repeat': -1})
else
  " http://vim.wikia.com/wiki/Timer_to_execute_commands_periodically
  function! LoadThemeTimer()
    call LoadTheme(1)
    call feedkeys("f\e")
  endfunction
  autocmd CursorHold * call LoadThemeTimer()
endif
