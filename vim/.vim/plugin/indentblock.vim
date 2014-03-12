" -*- vim -*-
" FILE: indentblock.vim
" LAST MODIFICATION: 2007-03-30
" (C) Copyright 2007 Jonathan Claggett <jonathan@claggett.org>
" Version: 1.2

" USAGE:
"
" Just source this script when editing code.
"
" Two new motions (ii, ai) will be added to your visual and operater-pending
" modes. These motions are based on the amount of indentation for either the
" current visual selection or for the current line. Note that these motions
" are particually useful for Python applications (which use indentation
" syntacically) and so an exception is made for python programs in which the
" trailing line of an indented block is never selected.
"
" Example commands:
"   <ii     -- Indent the current block of indented code.
"   cii     -- Change the "                         "   .
"   vai     -- visually select the block of indented code and the lines before
"              and after the current block.
"   vaiai   -- visually select the parent's block of indented code and the
"              lines before and after the parent's block.
"
" REQUIREMENTS:
" vim (>= 7)
"
" Shortcuts:
"   ii      -- Specify the internal indent block. All blank lines will be a
"              part of the range.
"   ai      -- Specify the indent block plus the leading outdented line and
"              the trailing line. Exception: in Python, the trailing outdented
"              line is never selected.

" Setup the ai and ii commands in visual mode.
vmap ai :call SelectIndentBlock(0)<CR>
vmap ii :call SelectIndentBlock(1)<CR>

" Setup the ai and ii commands in operator pending mode.
omap ai :call SelectIndentBlock(0)<CR>
omap ii :call SelectIndentBlock(1)<CR>

function! Empty(line)
    return match(getline(a:line), '^\s*$') != -1
endfunction

function! SelectIndentBlock(inner) range

    let s:firstline = a:firstline
    let s:lastline = a:lastline
    let s:indent = -1

    " Find the least indented, non-empty line in our given range.
    let s:i = s:lastline
    while s:i >= s:firstline
        if !Empty(s:i) && ( s:indent == -1 || s:indent > indent(s:i) )
            let s:indent = indent(s:i)
        endif
        let s:i -= 1
    endwhile

    " If we don't have a valid indentation within the range, look above and
    " below the range for a non-empty line and use the bigger indentation of
    " the two (above and below).
    if s:indent == -1

        let s:i = s:firstline - 1
        while s:i >= 1
            if !Empty(s:i)
                let s:indent = indent(s:i)
                break
            endif
            let s:i -= 1
        endwhile

        let s:i = s:lastline + 1
        while s:i <= line('$')
            if !Empty(s:i)
                if s:indent == -1 || s:indent < indent(s:i)
                    let s:indent = indent(s:i)
                endif
                break
            endif
            let s:i += 1
        endwhile

        " If we still don't have an indentation to work with, just assume 0.
        if s:indent == -1
            let s:indent = 0
        endif
    endif

    " Optimization: when we have a no indentation, select the whole file and
    " skip the following two while loops.
    if s:indent == 0
        let s:firstline = 1
        let s:lastline = line('$')
    endif

    " Find the starting line of the indent block
    while s:firstline > 1
        let s:firstline -= 1
        if !Empty(s:firstline) && s:indent > indent(s:firstline)
            if a:inner
                let s:firstline += 1
            endif
            break
        endif
    endwhile

    " Find the ending line of the indent block
    while s:lastline < line('$')
        let s:lastline += 1
        if !Empty(s:lastline) && s:indent > indent(s:lastline)
            if a:inner || &filetype == 'python'
                let s:lastline -= 1
            endif
            break
        endif
    endwhile

    execute 'normal ' . s:firstline . 'G|V' . s:lastline . 'G|'
endfunction

" vim:set et sts=4 sw=4:
