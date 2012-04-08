if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

" Tabs aren't allowed
setlocal expandtab

" No post-modifications to the current line's indent except for ^F
setlocal indentkeys=!^F,o,O

" Don't use standard indent rules
setlocal noautoindent
setlocal nosmartindent
setlocal nocindent

" Use custom indenting based on previous lines
setlocal indentexpr=GetOuterlineIndent()
function! GetOuterlineIndent()

  " Search back until the parentheses/braces are balanced
  let balance = 0
  let line_number = v:lnum
  while line_number > 1

    " Grab the next line
    let line_number -= 1
    let full_line = getline(line_number)

    " Strip out single-line comments (leave block comments)
    let without_comment = substitute(full_line, '\(#[()]\)\@<!#\([()]#\)\@!.*', '', '')

    " Update the balance based on this line
    let lefts = substitute(without_comment, '[^({]', '', 'g')
    let rights = substitute(without_comment, '[^})]', '', 'g')
    let balance += strlen(lefts) - strlen(rights)

    " Stop at a neutral or positive (left) balance
    if balance >= 0
      break
    endif
  endwhile

  if line_number == 1
    " If the start of the file was reached without a balance, reset to zero
    return 0
  else
    " For neutral balances, use the matched line's indent
    " For positive (left) balances, indent by one
    return indent(line_number) + (balance == 0 ? 0 : &sw)
  endif
endfunction

" vim:sw=2
