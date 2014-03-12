" special measures for verizon text messages
" $Id: mail_mutt-alias-completion.vim 2550 2007-06-21 16:01:30Z agriffis $
"
" Copyright 2008 Aron Griffis <agriffis n01se.net>
" Released under the GNU GPL v2

" move cursor to the start for searches
call cursor(1,1)

" don't trip on 'e'dit message
if getline(1) =~ '^From ' | finish | endif

" find the header/body separator line
function! SetBodySep()
  call cursor(1,1)
  let s:bodysep = search('^$', 'cnW')
  if s:bodysep == 0
    let s:bodysep = line("$") + 1
  endif
endfunction
call SetBodySep()

" only run on vtext messages
function! SearchN(regex, flags, stopline)
  return (v:version >=700 && a:stopline > 0) ?
        \ search(a:regex, a:flags, a:stopline) :
        \ search(a:regex, a:flags)
endfunction
if SearchN('^\(To\|Cc\):.*[vV][tT][eE][xX][tT]', 'cnW', s:bodysep) == 0
  finish
endif

" join header continuations
exe "silent! 0,".s:bodysep."s/ *\\n[\\t ][\\t ]*/ /g"
call SetBodySep()

" if the full message is in the body, collect it to move to the subject
let s:txtmsg = ""
call cursor(line("$"), 1)
normal! {
let s:lastparasep = line(".")
if s:lastparasep <= s:bodysep
  " skip attribution line
  let s:lastparasep = s:bodysep + 1
endif
let s:txtline = SearchN('[^>[:blank:]]', 'bcnW', s:lastparasep)
if s:txtline > s:lastparasep
  let s:txtmsg = getline(s:txtline)
  let s:txtmsg = substitute(s:txtmsg, '^[>[:blank:]]*', '', '')
  let s:txtmsg = substitute(s:txtmsg, '\s*$', '', '')
  let s:txtmsg = substitute(s:txtmsg, '\s\+', ' ', 'g')
endif

" remove the body entirely, including separator line.
" assumed by FindHdr and the header movements
exe "silent! ".s:bodysep.",$d"

" find a header, setting cursor position.
" if header isn't found, cursor doesn't move.
function! FindHdr(hdr)
  let l:pos = getpos(".")
  call cursor(1,1)
  if search("^".a:hdr, 'cW')
    return 1
  else
    call setpos(".", l:pos)
    return 0
  end
endfunction

let s:alreadyx = 0
if FindHdr("X-Subject:")
  move $
  let s:alreadyx = 1
end

if FindHdr("Subject:")
  move $
end

" if replying with no X-Subject, do the switcheroo
if s:alreadyx == 0 && FindHdr("In-Reply-To:") && FindHdr("Subject: .")
  if s:txtmsg != ""
    " replace subject with complete text message from body text
    call setline(".", "X-Subject: ".s:txtmsg)
  else
    " nothing in body, simply prepend subject with X-
    s/^/X-/
  endif
  normal oSubject: 
else
  " in case FindHdr("In-Reply-To:") but FindHdr("Subject: .") fails
  call FindHdr("Subject:")
end

" vimrc will move cursor to saved position for this file; prevent that
delmarks \"

" no wrapping desired
set paste

" leave us in append mode
startinsert!
