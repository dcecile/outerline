if exists("b:current_syntax")
  finish
endif

" TODO encourage users to add their own keywords to their .vimrc

syntax case match

syntax keyword outerlineKeyword def var fun use num true false when else
highlight def link outerlineKeyword Keyword

syntax match outerlineDelimiter display /(\|,\|;\|)/
highlight def link outerlineDelimiter Delimiter

highlight def link outerlineComment Comment

syntax match outerlineComment display /#.*/
highlight def link outerlineComment Comment

syntax region outerlineBlockComment start=/#(#/ end=/#)#/ contains=outerlineBlockComment
highlight def link outerlineBlockComment Comment

syntax region outerlineInterpolationEscape matchgroup=outerlineDelimiter start=/(/ end=/)/ contained contains=TOP

syntax region outerlineInterpolation start=/{/ end=/}/ contains=outerlineInterpolationEscape
highlight def link outerlineInterpolation String

" vim:sw=2
