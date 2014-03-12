" Vim syntax file
" Language:	   DokuWiki
" Version:     0.1
" Maintainer:	 Bill Powell <bill@billpowellisalive.com> http://billpowellisalive.com
" Last Change: 2008 Sep 11, 12:53 Thu

"Based on Wikipedia.vim syntax file.  Still rather a hack.
"Please let me know if you find errors or make improvements.
"Do note the heading mappings below, though. Use 
"
"TODO Might have to tweak Wikimedia.vim because at the end it unlets main_syntax. Hmm.
"
"AUTOMATIC MATCHING {{{1

"At present, you have to activate this highlighting manually.
":se ft=dokuwiki

"because there isn't a canonical extension for DokuWiki
"files (at least, that I know of). However, you can set all
"*.txt files to automatically be set to DokuWiki if you
"wish.
"
"(Modified from http://en.wikipedia.org/wiki/Wikipedia:Text_editor_support#Vim)

"Make or edit $HOME/.vim/ftdetect/txt.vim.
"And, without comments, add the following:
"
"augroup filetypedetect
	"au BufNewFile,BufRead *.txt,*.wiki setf dokuwiki
"augroup END

"}}}1
"
"==============================================
"And now, the syntax file:

syntax clear
runtime syntax/Wikipedia.vim


"From Wikipedia.vim
"Need this function for html.
"
if version < 508
  command! -nargs=+ HtmlHiLink hi link <args>
else
  command! -nargs=+ HtmlHiLink hi def link <args>
endif
let main_syntax = 'html'


"==============================================

"Need to clear wikiLink, start over.
syn clear wikiLink 
"Note you don't want to match on \\ if it's http:\\
"Fortunately, a judicious match of wikiLink trumps wikiItalic.
syn region wikiLink start="\[\[" end="\]\]\(s\|'s\|es\|ing\|\)" contains=wikiLink,wikiTemplate
"Special match for links not in brackets.
syn region wikiHttp start=+\(\(http\|https\|ftp\|gopher\|news\|mailto\):\/\/\|www\.\)+ end=+ +me=e-1

syn match wikiEmail /<[a-zA-Z_.0-9-]*@[a-zA-Z_.0-9-]*>/
syn region wikiItalic			start=+\/\/+	end=+\/\/+ contains=@Spell,wikiLink,wikiItalicBold
syn region wikiBold				start=+\*\*+			end=+\*\*+ contains=@Spell,wikiLink,wikiBoldItalic
syn region wikiBoldAndItalic	start=+'''''+		end=+'''''+ contains=@Spell,wikiLink

"TODO Make combinations work. Maybe.

syn region wikiUnderline			start=+__+	end=+__+ contains=@Spell,wikiLink
syn match wikiLinebreak /\\\\/ 

"Wikipedia italic is Dokuwiki mono. Hmm.
syn region wikiMono			start=+'\@<!'''\@!+	end=+''+ contains=@Spell
syn region wikiDel			start=+<del>+	end=+</del>+ contains=@Spell


"syn clear wikiParaFormatChar

"Too many emoticons.
syn match wikiKeyword /\(8-)\|8-O\|:-(\|:-)\|=)\|:-\/\|:-\\\\\|:-?\|:-D\|:-P\|:-O\|:-X\|:-|\|;-)\|\^_\^\|:?:\|:!:\|LOL\|FIXME\|DELETEME\)/
"TODO Get the broken ones to work. :)
"Typeset characters
syn match wikiKeyword /\(->\|<\(-\|=\)\(>\)\=\|=>\|<=\|>>\|<<\|--\(-\)\=\|640x480\|(c)\|(tm)\|(r)\)/
"TODO Brackets
"syn match wikiKeyword /\[\[\|\]\]\|{{\|}}/ containedin=wikiLink

"Lists
syn match wikiKeyword /^\(\s\s\)*[*-] / containedin=wikiPre

syn region wikiNowiki start=+%%+ end=+%%+
syn region wikiNowiki start=+<nowiki>+ end=+</nowiki>+

"TODO : Fix <code> hack, which doesn't really keep all code snippets
"clean.
syn region wikiCode start=+<\(file\|code\)+ms=s+5 end=+</\(file\|code\)>+me=e-7 contains=@Spell 
"Dangerous things in the dang code block.
"TODO figure out how to not have to match these individually.
"C comments: eternal bold
syn match wikiKeyword /\/\*\*/ 

syn region wikiFootnote start=+((+ end=+))+
syn region wikiInstruction start=+\~\~+ end=+\~\~+

syn match wikiQ1 /^\s*>.*/ containedin=wikiPre
syn match wikiQ2 /^\s*>>.*/ containedin=wikiPre
syn match wikiQ3 /^\s*>>>.*/ containedin=wikiPre
syn match wikiQ4 /^\s*>>>>.*/ containedin=wikiPre
"Four is quite enough, young man.

"Dokuwiki headings are the reverse of Wikipedia headings: H1 is
"====== H1 ======, not = H1 =. 
"It looks cooler, but you need a mapping for hi-level headings!
syn region wikiH6 start="^=" 		end="=" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiH5 start="^==" 		end="==" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiH4 start="^===" 		end="===" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiH3 start="^====" 	end="====" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiH2 start="^=====" 	end="=====" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiH1 start="^======" 	end="======" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink



"Special tags: probably only work with div-shorthand plugin by Joe Lapp.
"See http://wiki.splitbrain.org/plugin:div_span_shorthand
"I'm using the modified version at the bottom of the page.
"Allows you to insert div tags when you need them without needing 
"to allow html.

"Blockquote and Cite. 
"To use these, you'll have to use a strict syntax.
"
"#blockquote[
"Your quote can be as many lines as you want.
"But when you're done, the final tag must be on its own line.
"This is so you can have an option citation:
"#cite[Kenneth Grahame, //Wind in the Willows//]#
"]#
"
"If the final tag isn't on its own line, it won't work.
"
"Also note that this is div.blockquote and div.cite, NOT the html tags
"<blockquote> and <cite>. You'll want to keep that in mind for your
"css file. :)
"
"If DokuWiki didn't insert <BR>'s after each line in a blockquote, you
"wouldn't need this silliness.
"
syn match wikiKeyword /#\(blockquote\|cite\)\[/ containedin=wikiBlockquote
"TODO: Get ending bracket to match without breaking Blockquote
"environment.
"syn match wikiKeyword /\]#/ containedin=wikiBlockquote,wikiCite
syn region wikiBlockquote start=+^#blockquote\[+ 	end=+^\]#+ contains=@Spell,wikiLink,wikiCite,wikiParaFormatChar
syn region wikiCite start=+^#cite\[+ 	end=+\]#+ oneline contains=@Spell,wikiLink,wikiKeyword

"Comments: requires 'comments' plugin by Esther Bruner.
syn clear htmlCommentError
"TODO Get to work for multi-line comments.
syn region wikiComment start=+\/\*+	end=+\*\/+ contains=wikiPre

"COLORS not covered in Wikipedia.vim

hi link wikiHttp	wikiLink
hi link wikiEmail	wikiLink
hi link wikiUnderline	htmlUnderline
"NOTE : Ignore is occasionally invisible, depending on your scheme.
hi link wikiNowiki	Ignore
hi link wikiCode wikiPre
hi link wikiInstruction Exception
hi link wikiMono	Todo
hi link wikiDel	Error
hi link wikiLinebreak	Keyword
hi link wikiKeyword	Keyword
hi link wikiBlockquote Type
hi link wikiComment Comment
"Perhaps it's confusing to have anything besides Comments be
"highlighted as comments. But I figure comments in wikis will be quite
"rare. You may disagree.
hi link wikiFootnote Comment
hi link wikiCite Comment

"The quote levels will tend to intersect with the headings,
"depending on color scheme. Ah well.
"If you go to syntax.txt and look at the NAMING CONVENTIONS, you'll
"see I tried to choose groups here that'd match up with lower-level
"headings, to avoid confusion whenever possible. Basically, work my
"way back UP the ladder with quotes.
hi link wikiQ1 StorageClass
hi link wikiQ2 Conditional
hi link wikiQ3 Include
hi link wikiQ4 String

"Colors I relinked.
hi link wikiPre Special

"Why not give each heading a different color?
hi link htmlH1	Title 
hi link htmlH2	Identifier
hi link htmlH3	Constant
hi link htmlH4	PreProc   
hi link htmlH5	Statement 
hi link htmlH6	Type



"Tables need to come after this, for some reason.
"Tables
syn match wikiKeyword /[|\^]/ containedin=wikiPre,wikiTableCell,wikiTableHeading
syn match wikiTableCell /\s*|.*/ containedin=wikiPre
syn match wikiTableHeading /\s*\^.*/ containedin=wikiPre


hi link wikiTableCell PreCondit
hi link wikiTableHeading Character

" CLOSE DOWN, from Wikipedia.vim
let b:current_syntax = "html"

delcommand HtmlHiLink

if main_syntax == 'html'
  unlet main_syntax
endif
