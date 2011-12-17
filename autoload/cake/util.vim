" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.

let s:save_cpo = &cpo
set cpo&vim

" Function: cake#util#camelize(word) {{{
" hoge_fuga -> HogeFuga
" hogefuga -> Hogefuga
" HogeFuga -> HogeFuga
function! cake#util#camelize(word)

  let word = a:word
  if word == ''
    return word
  endif

  if word =~# '^[A-Z]\+[a-z0-9]\+[A-Z]\+[a-z0-9]\+'
    return word
  endif

  " To Upper Camel Case
  return join(map(split(word, '_'), 'toupper(v:val[0]) . tolower(v:val[1:])'), '')

endfunction "}}}
" Function: cake#util#decamelize(word) {{{
" HogeFuga -> hoge_fuga
" HOGEFUGA -> hogefuga
function! cake#util#decamelize(word)

  let word = a:word
  if word == ''
    return word
  endif

  " To snake_cake
  let result = ''

  if word =~# '^[A-Z]\+$'
   let result = tolower(word)
  else
    for c in split(word, '\zs')
      if c =~# '[A-Z]'
        let result = result . '_' . tolower(c)
      else 
        let result = result . c
      endif
    endfor

    if result[0] == '_'
      let result = result[1:]
    endif
  endif

  return result

endfunction "}}}

" Function: cake#util#singularize(word) {{{
" rails.vim(http://www.vim.org/scripts/script.php?script_id=1567)
" rails#singularize
" ============================================================
function! cake#util#singularize(word)

  let word = a:word
  if word == ''
    return word
  endif

  let word = substitute(word, '\v\Ceople$', 'ersons', '')
  let word = substitute(word, '\v\C[aeio]@<!ies$','ys', '')
  let word = substitute(word, '\v\Cxe[ns]$', 'xs', '')
  let word = substitute(word, '\v\Cves$','fs', '')
  let word = substitute(word, '\v\Css%(es)=$','sss', '')
  let word = substitute(word, '\v\Cs$', '', '')
  let word = substitute(word, '\v\C%([nrt]ch|tatus|lias)\zse$', '', '')
  let word = substitute(word, '\v\C%(nd|rt)\zsice$', 'ex', '')

  return word
endfunction
" }}}
" Function: cake#util#pluralize(word) {{{
" rails.vim(http://www.vim.org/scripts/script.php?script_id=1567)
" rails#pluralize
" ============================================================
function! cake#util#pluralize(word)

  let word = a:word
  if word == ''
    return word
  endif

  let word = substitute(word, '\v\C[aeio]@<!y$', 'ie', '')
  let word = substitute(word, '\v\C%(nd|rt)@<=ex$', 'ice', '')
  let word = substitute(word, '\v\C%([osxz]|[cs]h)$', '&e', '')
  let word = substitute(word, '\v\Cf@<!f$', 've', '')
  let word .= 's'
  let word = substitute(word, '\v\Cersons$','eople', '')

  return word
endfunction
" }}}

" Function: cake#util#echo_warning(message) {{{
function! cake#util#echo_warning(message)
  echohl WarningMsg | redraw | echo  a:message | echohl None
endfunction " }}}

" Function: cake#util#open_file(path, option, line) {{{
" ============================================================
function! cake#util#open_file(path, option, line)

  if !bufexists(a:path)
    exec "badd " . a:path
  endif

  let buf_no = bufnr(a:path)
  if buf_no != -1
    if a:option == 's'
      exec "sb" . buf_no
    elseif a:option == 'v'
      exec "vert sb" . buf_no
    elseif a:option == 't'
      exec "tabedit"
      exec "b" . buf_no
    else
      exec "b" . buf_no
    endif

    if type(a:line) == type(0) && a:line > 0
      exec a:line
      exec "normal z\<CR>"
      exec "normal ^"
    endif

  endif
endfunction
" }}}

" Function: cake#util#confirm_create_file(path) {{{
" ============================================================
function! cake#util#confirm_create_file(path)
  let choice = confirm(a:path . " is not found. Do you make a file ?", "&Yes\n&No", 1)

  if choice == 0
    " Was interrupted. Using Esc or Ctrl-C.
    return 0
  elseif choice == 1
    " TODO: A copy of the skeleton might be good?
    let result1 = system("mkdir -p " . fnamemodify(a:path, ":p:h"))
    let result2 = system("touch " . a:path)
    if strlen(result1) != 0 && strlen(result2) != 0
      call cake#util#echo_warning(result2)
      return 0
    else
      return 1
    endif
  endif

  return 0
endfunction
" }}}

" Function: cake#util#open_tail_log_window() {{{
" ============================================================
let s:log_buffers = {}
function! cake#util#open_tail_log_window(path,window_size)

  if !filereadable(a:path)
    call cake#util#echo_warning(a:path . " is not readable.")
    return
  endif

  let win_no = bufwinnr(a:path)
  if win_no != -1
    " If the window is not open, open & move.
    if winnr() != win_no
      exec win_no . "wincmd w"
      exec "normal G"
    endif
  else
    " create single scratch buffer.
    if !has_key(s:log_buffers, a:path)
      exec "badd " . a:path
      let s:log_buffers[a:path] = bufnr(a:path)
    endif

    if s:log_buffers[a:path] != -1
      exec "setlocal splitbelow"
      exec "silent sb" . s:log_buffers[a:path]
      exec "setlocal nosplitbelow"
      exec "silent resize " . a:window_size
      exec "setlocal buftype=nofile"
      exec "setlocal bufhidden=hide"
      exec "setlocal noswapfile"
      exec "setlocal noreadonly"
      " exec "setlocal updatetime=1000"
      exec "setlocal autoread"
      exec "normal G"

      " auto reloadable setting.
      autocmd CursorHold <buffer> call cake#util#reload_buffer()
      autocmd CursorHoldI <buffer> call cake#util#reload_buffer()
      autocmd FileChangedShell <buffer> call cake#util#reload_buffer()
      autocmd BufEnter <buffer> call cake#util#reload_buffer()
    endif
  endif
endfunction
" }}}

" Function: cake#util#reload_buffer() {{{
" ============================================================
function! cake#util#reload_buffer()
  exec "silent edit"
  exec "normal G"
  echo bufname("%"). " -> Last Read: " . strftime("%Y/%m/%d %X")
endfunction
" }}}

" Function: cake#util#strtrim(string) {{{
function! cake#util#strtrim(string)
  return substitute(substitute(a:string, '^\s\+', "", ""), '\s\+$', "", "")
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
