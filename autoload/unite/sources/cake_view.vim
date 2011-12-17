" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.

let s:save_cpo = &cpo
set cpo&vim

let s:unite_source_view = {
      \ 'name' : 'cake_view',
      \ 'description' : 'CakePHP Views',
      \ 'hooks' : {},
      \ }

function! s:unite_source_view.gather_candidates(args, context) "{{{
  let candidates = []

  if len(a:context.source__controllers) == 0
    call cake#util#echo_warning("No controller in current buffer. [Usage] :Unite cake_view:{controller-name},{controller-name}...")
    return candidates
  endif

  for i in a:context.source__controllers
    " default
    for path in split(globpath(g:cake.paths.views .cake#util#decamelize(i) . "/", "*.ctp"), "\n")
      call add(candidates, {
            \ 'word' : '(No Theme) ' . fnamemodify(path, ":t:r"),
            \ 'kind' : 'file',
            \ 'source' : 'cake_view',
            \ 'action__path' : path,
            \ 'action__directory' : fnamemodify(path,":p:h"),
            \ })
    endfor

    " every theme
    for theme in items(g:cake.get_themes())
      for path in split(globpath(theme[1] . i . "/", "*.ctp"), "\n")
        call add(candidates, {
              \ 'word' : '(' . theme[0] . ') ' . fnamemodify(path, ":t:r"),
              \ 'kind' : 'file',
              \ 'source' : 'cake_view',
              \ 'action__path' : path,
              \ 'action__directory' : fnamemodify(path,":p:h"),
              \ })
      endfor
    endfor
  endfor

  return candidates
endfunction "}}}
function! s:unite_source_view.hooks.on_init(args, context) "{{{
  " get controller's list
  let controllers = []

  if len(a:args) == 0
    if g:cake.is_controller(expand("%:p"))
      call add(controllers, g:cake.path_to_name_controller(expand("%:p")))
    endif
  else
    for i in split(a:args[0], ",")
      if g:cake.is_controller(g:cake.name_to_path_controller(i))
        call add(controllers, i)
      elseif g:cake.is_controller(g:cake.name_to_path_controller(cake#util#pluralize(i)))
        " try the plural form.
        call add(controllers, cake#util#pluralize(i))
      endif
    endfor
  endif

  let a:context.source__controllers = controllers

endfunction "}}}
function! unite#sources#cake_view#define() "{{{
    return s:unite_source_view
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
