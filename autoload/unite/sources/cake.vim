" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.

let s:save_cpo = &cpo
set cpo&vim

let s:is_fullname = 1

" UniteSource: cake_controller "{{{
" ============================================================
let s:unite_source_controller = {
      \ 'name' : 'cake_controller',
      \ 'description' : 'CakePHP Controllers',
      \ }

function! s:unite_source_controller.gather_candidates(args, context)
  let candidates = []

  try
    for i in items(g:cake.get_controllers(s:is_fullname))
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_controller',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction
" }}}
" UniteSource: cake_component "{{{
" ============================================================
let s:unite_source_component = {
      \ 'name' : 'cake_component',
      \ 'description' : 'CakePHP Components',
      \ }

function! s:unite_source_component.gather_candidates(args, context)
  let candidates = []

  try
    for i in items(g:cake.get_components(s:is_fullname))
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_component',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction
" }}}
" UniteSource: cake_model "{{{
" ============================================================
let s:unite_source_model = {
      \ 'name' : 'cake_model',
      \ 'description' : 'CakePHP Models',
      \ }

function! s:unite_source_model.gather_candidates(args, context)
  let candidates = []
  
  try
    for i in items(g:cake.get_models())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_model',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction " }}}
" UniteSource: cake_behavior "{{{
" ============================================================
let s:unite_source_behavior = {
      \ 'name' : 'cake_behavior',
      \ 'description' : 'CakePHP Behaviors',
      \ }

function! s:unite_source_behavior.gather_candidates(args, context)
  let candidates = []

  try
    for i in items(g:cake.get_behaviors(s:is_fullname))
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_behavior',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction
" }}}
" UniteSource: cake_view "{{{
" ============================================================
let s:unite_source_view = {
      \ 'name' : 'cake_view',
      \ 'description' : 'CakePHP Views',
      \ 'hooks' : {},
      \ }

function! s:unite_source_view.gather_candidates(args, context) "{{{
  let candidates = []

  try
    if len(a:context.source__controllers) == 0
      call cake#util#echo_warning("No controller in current buffer. [Usage] :Unite cake_view:{controller-name},{controller-name}...")
      return candidates
    endif

    for i in a:context.source__controllers
      " default
      for path in split(globpath(g:cake.paths.views .i . "/", "*.ctp"), "\n")
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
  catch
  endtry

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
"}}}
" UniteSource: cake_helper "{{{
" ============================================================
let s:unite_source_helper = {
      \ 'name' : 'cake_helper',
      \ 'description' : 'CakePHP Helpers',
      \ }

function! s:unite_source_helper.gather_candidates(args, context)
  let candidates = []

  try
    for i in items(g:cake.get_helpers(s:is_fullname))
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_helper',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction
" }}}
" UniteSource: cake_config "{{{
" ============================================================
let s:unite_source_config = {
      \ 'name' : 'cake_config',
      \ 'description' : 'CakePHP Configs',
      \ }

function! s:unite_source_config.gather_candidates(args, context)
  let candidates = []

  try
    for i in items(g:cake.get_configs())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_config',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction
" }}}
" UniteSource: cake_fixture "{{{
" ============================================================
let s:unite_source_fixture = {
      \ 'name' : 'cake_fixture',
      \ 'description' : 'CakePHP Fixtures',
      \ }

function! s:unite_source_fixture.gather_candidates(args, context)
  let candidates = []

  try
    for i in items(g:cake.get_fixtures(s:is_fullname))
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_fixture',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction

" }}}
" UniteSource: cake_shell "{{{
" ============================================================
let s:unite_source_shell = {
      \ 'name' : 'cake_shell',
      \ 'description' : 'CakePHP Shells',
      \ }

function! s:unite_source_shell.gather_candidates(args, context)
  let candidates = []

  try
    for i in items(g:cake.get_shells(s:is_fullname))
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_shell',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction
" }}}
" UniteSource: cake_task "{{{
" ============================================================
let s:unite_source_task = {
      \ 'name' : 'cake_task',
      \ 'description' : 'CakePHP Tasks',
      \ }

function! s:unite_source_task.gather_candidates(args, context)
  let candidates = []

  try
    for i in items(g:cake.get_tasks(s:is_fullname))
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_task',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction
" }}}
" UniteSource: cake_core "{{{
" ============================================================
let s:unite_source_core = {
      \ 'name' : 'cake_core',
      \ 'description' : 'CakePHP Core Libraries',
      \ }

function! s:unite_source_core.gather_candidates(args, context)
  let candidates = []

  try
    for i in items(g:cake.get_cores())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_core',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction
" }}}
" UniteSource: cake_lib "{{{
" ============================================================
let s:unite_source_lib = {
      \ 'name' : 'cake_lib',
      \ 'description' : 'CakePHP 1st party Libraries',
      \ }

function! s:unite_source_lib.gather_candidates(args, context)
  let candidates = []

  try
    for i in items(g:cake.get_libs())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_lib',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor
  catch
  endtry

  return candidates
endfunction
" }}}

function! unite#sources#cake#define() "{{{
  let sources = [
        \ s:unite_source_controller,
        \ s:unite_source_component,
        \ s:unite_source_model,
        \ s:unite_source_behavior,
        \ s:unite_source_view,
        \ s:unite_source_helper,
        \ s:unite_source_config,
        \ s:unite_source_fixture,
        \ s:unite_source_shell,
        \ s:unite_source_task,
        \ s:unite_source_core,
        \ s:unite_source_lib,
        \ ]

  return sources
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
