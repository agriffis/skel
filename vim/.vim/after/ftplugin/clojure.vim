" Remove . from iskeyword so that it's easier to follow from
" (.createSiteDisplay manager) to createSiteDisplay by pressing ctrl-]
" Otherwise the dot becomes part of the word and the tag doesn't match.
setl isk-=.
