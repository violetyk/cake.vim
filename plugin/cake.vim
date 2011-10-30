" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.
" Last Change: 2011/10/29


" -----------------------------------------------
command! -n=0 Test :call s:test()
function! s:test()
  echo s:get_themes()
  " exec "!cake"

  " let hoge = 'php -r "'
  " let hoge = hoge . 'echo 123;'  . '"'
  " echo hoge
  " echo \"hogehoge\";'"
  " let result = system( hoge )
  " echo result
endfunction
" -----------------------------------------------
if exists('g:loaded_cake_vim')
  " finish
endif
if v:version < 700
  echoerr "[cake.vim] this plugin requires vim >= 7. Thank you for trying to use this plugin."
  finish
endif
let g:loaded_cake_vim = 1

let s:save_cpo = &cpo
set cpo&vim

" SECTION: Global Variables {{{
" Please write $MYVIMRC. (Also work to write.)
" ============================================================
" let g:cakephp_app = "/path/to/cakephp_root/app/"
" let g:cakephp_auto_set_project = 1
" let g:cakephp_use_theme = "admin"
if !exists('g:cakephp_log')
  let g:cakephp_log = {
        \ 'debug' : '',
        \ 'error' : '',
        \ 'query' : '/var/log/mysqld-query.log',
        \ 'access': '/usr/local/apache2/logs/access_log'
        \ }
endif


" Default Settings
" ============================================================
let g:cakephp_log_window_size = 15
" }}}
" SECTION: Script Variables {{{
" ============================================================
let s:cake_vim_version = '1.3.0'
let s:message_prefix = '[cake.vim] '
let s:paths = {}
let s:log_buffers = {}
" }}}

" Function: s:initialize() {{{
" ============================================================
function! s:initialize(path)

  " set app directory of the project.
  if a:path != ''
    let s:paths.app = fnamemodify(a:path, ":p")
  elseif exists("g:cakephp_app") && g:cakephp_app != ''
    let s:paths.app = g:cakephp_app
  endif

  if !exists("s:paths.app") || s:paths.app == '' || !isdirectory(s:paths.app)
    call s:echo_warning("Please set g:cakephp_app or :Cakephp {app}.")
    return
  endif

  let s:paths.controllers = s:paths.app . "controllers/"
  let s:paths.models      = s:paths.app . "models/"
  let s:paths.views       = s:paths.app . "views/"
  let s:paths.themes      = s:paths.views . "themed/"
  let s:paths.configs     = s:paths.app . "config/"
  let s:paths.components  = s:paths.app . "controllers/components/"
  let s:paths.shells      = s:paths.app . "vendors/shells/"
  let s:paths.tasks       = s:paths.shells . "tasks/"

  if !has_key(g:cakephp_log, 'debug') || g:cakephp_log['debug'] == ''
    let g:cakephp_log['debug'] = s:paths.app . "tmp/logs/debug.log"
  endif

  if !has_key(g:cakephp_log, 'error') || g:cakephp_log['error'] == ''
    let g:cakephp_log['error'] = s:paths.app . "tmp/logs/error.log"
  endif

endfunction
" }}}

" Function: s:get_controllers() {{{
" ============================================================
function! s:get_controllers()

  let controllers = {}

  for path in split(globpath(s:paths.app, "**/*_controller.php"), "\n")
    let name = s:path_to_name_controller(path)
    let controllers[name] = path
  endfor

  return controllers

endfunction
" }}}

" Function: s:get_models() {{{
" ============================================================
function! s:get_models()

  let models = {}

  for path in split(globpath(s:paths.models, "*.php"), "\n")
    let models[s:path_to_name_model(path)] = path
  endfor

  for path in split(globpath(s:paths.app, "*_model.php"), "\n")
    let name = substitute(s:path_to_name_model(path), "_model$", "", "")
    let models[name] = path
  endfor

  return models

endfunction
" }}}
" Function: s:get_views() {{{
" ============================================================
function! s:get_views(controller_name)

  let views = []

  " Extracting the function name.
  let cmd = 'grep -E "^\s*function\s*\w+\s*\(" ' . s:name_to_path_controller(a:controller_name)
  for line in split(system(cmd), "\n")

    let s = matchend(line, "\s*function\s*.")
    let e = match(line, "(")
    let func_name = strpart(line, s, e-s)

    " Callback functions are not eligible.
    if func_name !~ "^_" && func_name !=? "beforeFilter" && func_name !=? "beforeRender" && func_name !=? "afterFilter"
      let views = add(views , func_name)
    endif
  endfor

  return views

endfunction
" }}}
" Function: s:get_themes() {{{
" ============================================================
function! s:get_themes()

  let themes = {}

  for path in split(globpath(s:paths.themes, "*/"), "\n")
    let themes[s:path_to_name_theme(path)] = path
  endfor

  return themes

endfunction
" }}}
" Function: s:get_configs() {{{
" ============================================================
function! s:get_configs()

  let configs = {}

  for path in split(globpath(s:paths.configs, "*.php"), "\n")
    let configs[s:path_to_name_config(path)] = path
  endfor

  return configs

endfunction
" }}}
" Function: s:get_components() {{{
" ============================================================
function! s:get_components()

  let components = {}

  for path in split(globpath(s:paths.components, "*.php"), "\n")
    let components[s:path_to_name_component(path)] = path
  endfor

  return components

endfunction
" }}}
" Function: s:get_shells() {{{
" ============================================================
function! s:get_shells()

  let shells = {}

  for path in split(globpath(s:paths.shells, "*.php"), "\n")
    let shells[s:path_to_name_shell(path)] = path
  endfor

  return shells

endfunction
" }}}
" Function: s:get_tasks() {{{
" ============================================================
function! s:get_tasks()

  let tasks = {}

  for path in split(globpath(s:paths.tasks, "*.php"), "\n")
    let tasks[s:path_to_name_task(path)] = path
  endfor

  return tasks

endfunction
" }}}

" Function: s:jump_controller() {{{
" ============================================================
function! s:jump_controller(...)

  let split_option = a:1
  let target = ''
  let func_name = ''

  if a:0 >= 2
    " Controller name is specified in the argument.
    let target = a:2
  else
    " Controller name is inferred from the currently opened file (view or model).
    let path = expand("%:p")

    if s:is_view(path)
      let target = expand("%:p:h:t")
      let func_name = expand("%:p:t:r")
    elseif s:is_model(path)
      let target = s:pluralize(expand("%:p:t:r"))
    else
      return
    endif
  endif

  let controllers = s:get_controllers()

  if !has_key(controllers, target)

    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_controller(target))
      let controllers[target] = s:name_to_path_controller(target)
    else
      call s:echo_warning(target . "_controller is not found.")
      return
    endif
  endif


  " Jump to the line that corresponds to the view's function.
  let line = 0
  if func_name != ''
    let cmd = 'grep -n -E "^\s*function\s*' . func_name . '\s*\(" ' . s:name_to_path_controller(target) . ' | cut -f 1'
    " Extract line number from grep result.
    let n = matchstr(system(cmd), '\(^\d\+\)')
    if strlen(n) > 0
      let line = str2nr(n)
    endif
  endif

  call s:open_file(controllers[target], split_option, line)

endfunction
"}}}
" Function: s:jump_model() {{{
" ============================================================
function! s:jump_model(...)

  let split_option = a:1

  let target = ''

  if a:0 >= 2
    " Model name is specified in the argument.
    let target = a:2
  else
    " Model name is inferred from the currently opened controller file.
    let path = expand("%:p")

    if s:is_controller(path)
      let target = s:singularize(substitute(expand("%:p:t:r"), "_controller$", "", ""))
    else
      return
    endif
  endif

  let models = s:get_models()

  if !has_key(models, target)

    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_model(target))
      let models[target] = s:name_to_path_model(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(models[target], split_option, line)

endfunction
"}}}
" Function: s:jump_view() {{{
" ============================================================
function! s:jump_view(...)

  if !s:is_controller(expand("%:p"))
    call s:echo_warning("No controller in current buffer.")
    return
  endif

  let split_option = a:1
  let view_name = a:2

  if a:0 >= 3
    let theme = 'themed/' . a:3 . '/'
  else
    let theme = (exists("g:cakephp_use_theme") && g:cakephp_use_theme != '')? 'themed/' . g:cakephp_use_theme . '/' : ''
  endif

  let view_path = s:paths.views . theme . s:path_to_name_controller(expand("%:p")) . "/" . view_name . ".ctp"

  " If the file does not exist, ask whether to create a new file.
  if !filewritable(view_path)
    if !s:confirm_create_file(view_path)
      call s:echo_warning(view_path . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(view_path, split_option, line)

endfunction
"}}}
" Function: s:jump_controllerview() {{{
" ============================================================
function! s:jump_controllerview(...)

  if a:0 < 3
    return
  endif

  let split_option = a:1
  let controller_name = a:2
  let view_name = a:3

  if a:0 >= 4
    let theme = 'themed/' . a:4 . '/'
  else
    let theme = (exists("g:cakephp_use_theme") && g:cakephp_use_theme != '')? 'themed/' . g:cakephp_use_theme . '/' : ''
  endif

  let view_path = s:paths.views . theme . controller_name . "/" . view_name . ".ctp"

  if !filewritable(view_path)
    call s:echo_warning(view_path . " is not found.")
    return
  endif

  let line = 0
  call s:open_file(view_path, split_option, line)

endfunction
"}}}
" Function: s:jump_config() {{{
" ============================================================
function! s:jump_config(...)

  let split_option = a:1
  let target = a:2
  let configs = s:get_configs()

  if !has_key(configs, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_config(target))
      let configs[target] = s:name_to_path_config(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(configs[target], split_option, line)

endfunction
"}}}
" Function: s:jump_component() {{{
" ============================================================
function! s:jump_component(...)

  let split_option = a:1
  let target = a:2
  let components = s:get_components()

  if !has_key(components, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_component(target))
      let components[target] = s:name_to_path_component(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(components[target], split_option, line)

endfunction
"}}}
" Function: s:jump_shell() {{{
" ============================================================
function! s:jump_shell(...)

  let split_option = a:1
  let target = a:2
  let shells = s:get_shells()

  if !has_key(shells, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_shell(target))
      let shells[target] = s:name_to_path_shell(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(shells[target], split_option, line)

endfunction
"}}}
" Function: s:jump_task() {{{
" ============================================================
function! s:jump_task(...)

  let split_option = a:1
  let target = a:2
  let tasks = s:get_tasks()

  if !has_key(tasks, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_task(target))
      let tasks[target] = s:name_to_path_task(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(tasks[target], split_option, line)

endfunction
"}}}
" Function: s:tail_log() {{{
" ============================================================
function! s:tail_log(log_name)
  if !has_key(g:cakephp_log, a:log_name)
    call s:echo_warning(a:log_name . " is not found. please set g:cakephp_log['" . a:log_name . "'] = '/path/to/log_name.log'.")
    return
  endif

  call s:open_tail_log_window(g:cakephp_log[a:log_name])
endfunction
"}}}

" Function: s:path_to_name_controller() {{{
" ============================================================
function! s:path_to_name_controller(controller_path)
  return substitute(fnamemodify(a:controller_path, ":t:r"), "_controller$", "", "")
endfunction
" }}}
" Function: s:path_to_name_model() {{{
" ============================================================
function! s:path_to_name_model(model_path)
  return fnamemodify(a:model_path, ":t:r")
endfunction
" }}}
" Function: s:path_to_name_theme() {{{
" ============================================================
function! s:path_to_name_theme(theme_path)
  return fnamemodify(a:theme_path, ":p:h:t")
endfunction
" }}}
" Function: s:path_to_name_config() {{{
" ============================================================
function! s:path_to_name_config(config_path)
  return fnamemodify(a:config_path, ":t:r")
endfunction
" }}}
" Function: s:path_to_name_component() {{{
" ============================================================
function! s:path_to_name_component(component_path)
  return fnamemodify(a:component_path, ":t:r")
endfunction
" }}}
" Function: s:path_to_name_shell() {{{
" ============================================================
function! s:path_to_name_shell(shell_path)
  return fnamemodify(a:shell_path, ":t:r")
endfunction
" }}}
" Function: s:path_to_name_task() {{{
" ============================================================
function! s:path_to_name_task(task_path)
  return fnamemodify(a:task_path, ":t:r")
endfunction
" }}}
" Function: s:name_to_path_controller() {{{
" ============================================================
function! s:name_to_path_controller(controller_name)
  return s:paths.controllers . a:controller_name . "_controller.php"
endfunction
" }}}
" Function: s:name_to_path_model() {{{
" ============================================================
function! s:name_to_path_model(model_name)
  return s:paths.models . a:model_name . ".php"
endfunction
" }}}
" Function: s:name_to_path_config() {{{
" ============================================================
function! s:name_to_path_config(config_name)
  return s:paths.configs . a:config_name . ".php"
endfunction
" }}}
" Function: s:name_to_path_component() {{{
" ============================================================
function! s:name_to_path_component(component_name)
  return s:paths.components . a:component_name . ".php"
endfunction
" }}}
" Function: s:name_to_path_shell() {{{
" ============================================================
function! s:name_to_path_shell(shell_name)
  return s:paths.shells . a:shell_name . ".php"
endfunction
" }}}
" Function: s:name_to_path_task() {{{
" ============================================================
function! s:name_to_path_task(task_name)
  return s:paths.tasks . a:task_name . ".php"
endfunction
" }}}


" Function: s:is_view() {{{
" ============================================================
function! s:is_view(path)

  if filereadable(a:path) && match(a:path, s:paths.views) != -1 && fnamemodify(a:path, ":e") == "ctp"
    return 1
  endif

  return 0

endfunction
" }}}
" Function: s:is_model() {{{
" ============================================================
function! s:is_model(path)

  if filereadable(a:path) && match(a:path, s:paths.models) != -1 && fnamemodify(a:path, ":e") == "php"
    return 1
  endif

  return 0

endfunction
" }}}
" Function: s:is_controller() {{{
" ============================================================
function! s:is_controller(path)

  if filereadable(a:path) && match(a:path, s:paths.controllers) != -1 && match(a:path, "_controller\.php$") != -1
    return 1
  endif

  return 0

endfunction
" }}}

" Function: s:singularize() {{{
" rails.vim(http://www.vim.org/scripts/script.php?script_id=1567)
" rails#singularize
" ============================================================
function! s:singularize(word)

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
" Function: s:pluralize() {{{
" rails.vim(http://www.vim.org/scripts/script.php?script_id=1567)
" rails#pluralize
" ============================================================
function! s:pluralize(word)

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

" Function: s:get_complelist_controller() {{{
" ============================================================
function! s:get_complelist_controller(ArgLead, CmdLine, CursorPos)
  let controllers = s:get_controllers()
  let list = sort(keys(controllers))
  return filter(list, 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction
" }}}
" Function: s:get_complelist_model() {{{
" ============================================================
function! s:get_complelist_model(ArgLead, CmdLine, CursorPos)
  let models = s:get_models()
  let list = sort(keys(models))
  return filter(list, 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction
" }}}
" Function: s:get_complelist_view() {{{
" ============================================================
function! s:get_complelist_view(ArgLead, CmdLine, CursorPos)
  let args = split(a:CmdLine, '\W\+')
  let view_name = get(args, 1)
  let theme_name = get(args, 2)
  let themes = s:get_themes()

  if !s:is_controller(expand("%:p"))
    return []
  elseif count(s:get_views(s:path_to_name_controller(expand("%:p"))), view_name) == 0
    return filter(sort(s:get_views(s:path_to_name_controller(expand("%:p")))), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  elseif !has_key(themes, theme_name)
    return filter(sort(keys(themes)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  endif
endfunction
" }}}
" Function: s:get_complelist_controllerview() {{{
" ============================================================
function! s:get_complelist_controllerview(ArgLead, CmdLine, CursorPos)
  let args = split(a:CmdLine, '\W\+')
  let controller_name = get(args, 1)
  let view_name = get(args, 2)
  let theme_name = get(args, 3)
  let controllers = s:get_controllers()
  let themes = s:get_themes()

  if !has_key(controllers, controller_name)
    " Completion of the first argument.
    " Returns a list of the controller name.
    return s:get_complelist_controller(a:ArgLead, a:CmdLine, a:CursorPos)
  elseif count(s:get_views(controller_name), view_name) == 0
    " Completion of the second argument.
    " Returns a list of view names.
    " The view corresponds to the first argument specified in the controller.
    return filter(sort(s:get_views(controller_name)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  elseif !has_key(themes, theme_name)
    " Completion of the third argument.
    " Returns a list of theme names.
    return filter(sort(keys(themes)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  endif
endfunction
" }}}
" Function: s:get_complelist_config() {{{
" ============================================================
function! s:get_complelist_config(ArgLead, CmdLine, CursorPos)
  let configs = s:get_configs()
  let list = sort(keys(configs))
  return filter(sort(list), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction
" }}}
" Function: s:get_complelist_component() {{{
" ============================================================
function! s:get_complelist_component(ArgLead, CmdLine, CursorPos)
  let components = s:get_components()
  let list = sort(keys(components))
  return filter(sort(list), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction
" }}}
" Function: s:get_complelist_shell() {{{
" ============================================================
function! s:get_complelist_shell(ArgLead, CmdLine, CursorPos)
  let shells = s:get_shells()
  let list = sort(keys(shells))
  return filter(sort(list), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction
" }}}
" Function: s:get_complelist_task() {{{
" ============================================================
function! s:get_complelist_task(ArgLead, CmdLine, CursorPos)
  let tasks = s:get_tasks()
  let list = sort(keys(tasks))
  return filter(sort(list), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction
" }}}
" Function: s:get_complelist_log() {{{
" ============================================================
function! s:get_complelist_log(ArgLead, CmdLine, CursorPos)
  let list = sort(keys(g:cakephp_log))
  return filter(sort(list), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction
" }}}

" Function: s:echo_warning() {{{
" ============================================================
function! s:echo_warning(message)
  echohl WarningMsg | redraw | echo s:message_prefix . a:message | echohl None
endfunction
" }}}
" Function: s:open_file() {{{
" ============================================================
function! s:open_file(path, option, line)

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
" Function: s:confirm_create_file() {{{
" ============================================================
function! s:confirm_create_file(path)
  let choice = confirm(s:message_prefix . a:path . " is not found. Do you make a file ?", "&Yes\n&No", 1)

  if choice == 0
    " Was interrupted. Using Esc or Ctrl-C.
    return 0
  elseif choice == 1
    " TODO: A copy of the skeleton might be good?
    let result1 = system("mkdir -p " . fnamemodify(a:path, ":p:h"))
    let result2 = system("touch " . a:path)
    if strlen(result1) != 0 && strlen(result2) != 0
      call s:echo_warning(result2)
      return 0
    else
      return 1
    endif
  endif

  return 0
endfunction
" }}}
" Function: s:open_tail_log_window() {{{
" ============================================================
function! s:open_tail_log_window(path)

  if !filereadable(a:path)
    call s:echo_warning(a:path . " is not readable.")
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
      exec "silent resize " . g:cakephp_log_window_size
      exec "setlocal buftype=nofile"
      exec "setlocal bufhidden=hide"
      exec "setlocal noswapfile"
      exec "setlocal noreadonly"
      " exec "setlocal updatetime=1000"
      exec "setlocal autoread"
      exec "normal G"

      " auto reloadable setting.
      autocmd CursorHold <buffer> call s:reload_buffer()
      autocmd CursorHoldI <buffer> call s:reload_buffer()
      autocmd FileChangedShell <buffer> call s:reload_buffer()
      autocmd BufEnter <buffer> call s:reload_buffer()
    endif
  endif
endfunction
" }}}
" Function: s:reload_buffer() {{{
" ============================================================
function! s:reload_buffer()
  exec "silent edit"
  exec "normal G"
  " echo bufname("%"). " -> Last Read: " . strftime("%Y/%m/%d %X")
endfunction
" }}}

" SECTION: Auto commands {{{
"============================================================
if exists("g:cakephp_auto_set_project") && g:cakephp_auto_set_project == 1
  autocmd VimEnter * call s:initialize('')
endif
" }}}
" SECTION: Commands {{{
" ============================================================
" Initialized. If you have an argument, given that initializes the app path.
command! -n=? -complete=dir Cakephp :call s:initialize(<f-args>)

" * -> Controller
" Argument is Controller.
" When the Model or View is open, if no arguments are inferred from the currently opened file.
command! -n=? -complete=customlist,s:get_complelist_controller Ccontroller call s:jump_controller('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_controller Ccontrollersp call s:jump_controller('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_controller Ccontrollervsp call s:jump_controller('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_controller Ccontrollertab call s:jump_controller('t', <f-args>)

" * -> Model
" Argument is Model.
" When the Controller is open, if no arguments are inferred from the currently opened file.
command! -n=? -complete=customlist,s:get_complelist_model Cmodel call s:jump_model('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_model Cmodelsp call s:jump_model('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_model Cmodelvsp call s:jump_model('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_model Cmodeltab call s:jump_model('t', <f-args>)

" Controller -> View
" Argument is View (,Theme).
command! -n=+ -complete=customlist,s:get_complelist_view Cview call s:jump_view('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_view Cviewsp call s:jump_view('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_view Cviewvsp call s:jump_view('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_view Cviewtab call s:jump_view('t', <f-args>)

" * -> View
" Argument is Controller, View (,Theme).
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerview call s:jump_controllerview('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerviewsp call s:jump_controllerview('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerviewvsp call s:jump_controllerview('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerviewtab call s:jump_controllerview('t', <f-args>)

" * -> Config
" Argument is Config.
command! -n=1 -complete=customlist,s:get_complelist_config Cconfig call s:jump_config('n', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_config Cconfigsp call s:jump_config('s', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_config Cconfigvsp call s:jump_config('v', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_config Cconfigtab call s:jump_config('t', <f-args>)

" * -> Component
" Argument is Component.
command! -n=1 -complete=customlist,s:get_complelist_component Ccomponent call s:jump_component('n', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_component Ccomponentsp call s:jump_component('s', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_component Ccomponentvsp call s:jump_component('v', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_component Ccomponenttab call s:jump_component('t', <f-args>)

" * -> Shell
" Argument is Shell.
command! -n=1 -complete=customlist,s:get_complelist_shell Cshell call s:jump_shell('n', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_shell Cshellsp call s:jump_shell('s', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_shell Cshellvsp call s:jump_shell('v', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_shell Cshelltab call s:jump_shell('t', <f-args>)

" * -> Task
" Argument is Task.
command! -n=1 -complete=customlist,s:get_complelist_task Ctask call s:jump_task('n', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_task Ctasksp call s:jump_task('s', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_task Ctaskvsp call s:jump_task('v', <f-args>)
command! -n=1 -complete=customlist,s:get_complelist_task Ctasktab call s:jump_task('t', <f-args>)

" * -> Log
" Argument is Log name.
command! -n=1 -complete=customlist,s:get_complelist_log Clog call s:tail_log(<f-args>)
" }}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
