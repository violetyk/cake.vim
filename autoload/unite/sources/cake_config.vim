" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.

let s:save_cpo = &cpo
set cpo&vim

let s:unite_source_config = {
      \ 'name' : 'cake_config',
      \ 'description' : 'CakePHP Configs',
      \ }

function! s:unite_source_config.gather_candidates(args, context) "{{{
  let candidates = []
  for i in items(g:cake.get_configs())
    call add(candidates, {
          \ 'word' : i[0],
          \ 'kind' : 'file',
          \ 'source' : 'cake_config',
          \ 'action__path' : i[1],
          \ 'action__directory' : fnamemodify(i[1],":p:h"),
          \ })
  endfor

  return candidates
endfunction " }}}
function! unite#sources#cake_config#define() "{{{
    return s:unite_source_config
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
