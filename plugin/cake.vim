" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.
" Last Change: 2011/11/04


if exists('g:loaded_cake_vim')
  finish
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
let s:cake_vim_version = '1.4.0'
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

  let s:paths.controllers      = s:paths.app . "controllers/"
  let s:paths.models           = s:paths.app . "models/"
  let s:paths.behaviors        = s:paths.models . "behaviors/"
  let s:paths.views            = s:paths.app . "views/"
  let s:paths.helpers          = s:paths.views . "helpers/"
  let s:paths.themes           = s:paths.views . "themed/"
  let s:paths.configs          = s:paths.app . "config/"
  let s:paths.components       = s:paths.app . "controllers/components/"
  let s:paths.shells           = s:paths.app . "vendors/shells/"
  let s:paths.tasks            = s:paths.shells . "tasks/"
  let s:paths.behaviors        = s:paths.models . "behaviors/"
  let s:paths.test             = s:paths.app . "tests/cases/"
  let s:paths.testmodels       = s:paths.test . "models/"
  let s:paths.testbehaviors    = s:paths.test . "behaviors/"
  let s:paths.testcomponents   = s:paths.test . "components/"
  let s:paths.testcontrollers  = s:paths.test . "controllers/"
  let s:paths.testhelpers      = s:paths.test . "helpers/"
  let s:paths.fixtures         = s:paths.app  . "tests/fixtures/"

  if !has_key(g:cakephp_log, 'debug') || g:cakephp_log['debug'] == ''
    let g:cakephp_log['debug'] = s:paths.app . "tmp/logs/debug.log"
  endif

  if !has_key(g:cakephp_log, 'error') || g:cakephp_log['error'] == ''
    let g:cakephp_log['error'] = s:paths.app . "tmp/logs/error.log"
  endif

endfunction
" }}}

" Function: s:_get_dict() {{{
" ============================================================
function! s:_get_dict(object_path, pattern)

  let dict = {}

  for path in split(globpath(a:object_path, a:pattern), "\n")
    let name = s:path_to_name(path)
    let dict[name] = path
  endfor

  return dict

endfunction
" }}}
" Function: s:_get_dict_test() {{{
" ============================================================
function! s:_get_dict_test(object_path, pattern)

  let dict = {}

  for path in split(globpath(a:object_path, a:pattern), "\n")
    let name = s:path_to_name_test(path)
    let dict[name] = path
  endfor

  return dict

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
    let models[s:path_to_name_model(path)] = path
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
  return s:_get_dict(s:paths.configs, "*.php")
endfunction
" }}}
" Function: s:get_components() {{{
" ============================================================
function! s:get_components()
  return s:_get_dict(s:paths.components, "*.php")
endfunction
" }}}
" Function: s:get_shells() {{{
" ============================================================
function! s:get_shells()
  return s:_get_dict(s:paths.shells, "*.php")
endfunction
" }}}
" Function: s:get_tasks() {{{
" ============================================================
function! s:get_tasks()
  return s:_get_dict(s:paths.tasks, "*.php")
endfunction
" }}}
" Function: s:get_behaviors() {{{
" ============================================================
function! s:get_behaviors()
  return s:_get_dict(s:paths.behaviors, "*.php")
endfunction
" }}}
" Function: s:get_helpers() {{{
" ============================================================
function! s:get_helpers()
  return s:_get_dict(s:paths.helpers, "*.php")
endfunction
" }}}
" Function: s:get_testmodels() {{{
" ============================================================
function! s:get_testmodels()
  return s:_get_dict_test(s:paths.testmodels, "*.test.php")
endfunction
" }}}
" Function: s:get_testbehaviors() {{{
" ============================================================
function! s:get_testbehaviors()
  return s:_get_dict_test(s:paths.testbehaviors, "*.test.php")
endfunction
" }}}
" Function: s:get_testcomponents() {{{
" ============================================================
function! s:get_testcomponents()
  return s:_get_dict_test(s:paths.testcomponents, "*.test.php")
endfunction
" }}}
" Function: s:get_testcontrollers() {{{
" ============================================================
function! s:get_testcontrollers()

  let testcontrollers = {}

  for path in split(globpath(s:paths.testcontrollers, "*_controller.test.php"), "\n")
    let testcontrollers[s:path_to_name_testcontroller(path)] = path
  endfor

  return testcontrollers

endfunction
" }}}
" Function: s:get_testhelpers() {{{
" ============================================================
function! s:get_testhelpers()
  return s:_get_dict_test(s:paths.testhelpers, "*.test.php")
endfunction
" }}}
" Function: s:get_fixtures() {{{
" ============================================================
function! s:get_fixtures()

  let fixtures = {}

  for path in split(globpath(s:paths.fixtures, "*_fixture.php"), "\n")
    let fixtures[s:path_to_name_fixture(path)] = path
  endfor

  return fixtures

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
    " Controller name is inferred from the currently opened file (view or model or testcontroller).
    let path = expand("%:p")

    if s:is_view(path)
      let target = expand("%:p:h:t")
      let func_name = expand("%:p:t:r")
    elseif s:is_model(path)
      let target = s:pluralize(expand("%:p:t:r"))
    elseif s:is_testcontroller(path)
      let target = s:path_to_name_testcontroller(path)
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
    elseif s:is_testmodel(path)
      let target = s:path_to_name_test(path)
    elseif s:is_fixture(path)
      let target = s:path_to_name_fixture(path)
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
  let target = ''
  let components = s:get_components()

  if a:0 >= 2
    " Component name is specified in the argument.
    let target = a:2
  else
    " Component name is inferred from the currently opened testcomponent file.
    let path = expand("%:p")

    if s:is_testcomponent(path)
      let target = s:path_to_name_test(path)
    else
      return
    endif
  endif

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
" Function: s:jump_behavior() {{{
" ============================================================
function! s:jump_behavior(...)

  let split_option = a:1
  let target = ''
  let behaviors = s:get_behaviors()

  if a:0 >= 2
    " Behaivior name is specified in the argument.
    let target = a:2
  else
    " Behaivior name is inferred from the currently opened testbehavior file.
    let path = expand("%:p")

    if s:is_testbehavior(path)
      let target = s:path_to_name(path)
    else
      return
    endif
  endif

  if !has_key(behaviors, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_behavior(target))
      let behaviors[target] = s:name_to_path_behavior(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(behaviors[target], split_option, line)

endfunction
"}}}
" Function: s:jump_helper() {{{
" ============================================================
function! s:jump_helper(...)

  let split_option = a:1
  let target = ''
  let helpers = s:get_helpers()

  if a:0 >= 2
    " Helper name is specified in the argument.
    let target = a:2
  else
    " Helper name is inferred from the currently opened testhelper file.
    let path = expand("%:p")

    if s:is_testhelper(path)
      let target = s:path_to_name_test(path)
    else
      return
    endif
  endif

  if !has_key(helpers, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_helper(target))
      let helpers[target] = s:name_to_path_helper(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(helpers[target], split_option, line)

endfunction
"}}}
" Function: s:jump_testmodel() {{{
" ============================================================
function! s:jump_testmodel(...)

  let split_option = a:1
  let target = ''
  let testmodels = s:get_testmodels()

  if a:0 >= 2
    " Model name is specified in the argument.
    let target = a:2
  else
    " Model name is inferred from the currently opened controller file.
    let path = expand("%:p")

    if s:is_model(path)
      let target = s:path_to_name_model(path)
    elseif s:is_fixture(path)
      let target = s:path_to_name_fixture(path)
    else
      return
    endif
  endif

  if !has_key(testmodels, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_testmodel(target))
      let testmodels[target] = s:name_to_path_testmodel(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(testmodels[target], split_option, line)

endfunction
"}}}
" Function: s:jump_testbehavior() {{{
" ============================================================
function! s:jump_testbehavior(...)

  let split_option = a:1
  let target = ''
  let testbehaviors = s:get_testbehaviors()

  if a:0 >= 2
    " Behaivior name is specified in the argument.
    let target = a:2
  else
    " Behaivior name is inferred from the currently opened behavior file.
    let path = expand("%:p")

    if s:is_behavior(path)
      let target = s:path_to_name_test(path)
    else
      return
    endif
  endif

  if !has_key(testbehaviors, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_testbehavior(target))
      let testbehaviors[target] = s:name_to_path_testbehavior(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(testbehaviors[target], split_option, line)

endfunction
"}}}
" Function: s:jump_testcomponent() {{{
" ============================================================
function! s:jump_testcomponent(...)

  let split_option = a:1
  let target = ''
  let testcomponents = s:get_testcomponents()


  if a:0 >= 2
    " Component name is specified in the argument.
    let target = a:2
  else
    " Componen tname is inferred from the currently opened component file.
    let path = expand("%:p")

    if s:is_component(path)
      let target = s:path_to_name(path)
    else
      return
    endif
  endif

  if !has_key(testcomponents, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_testcomponent(target))
      let testcomponents[target] = s:name_to_path_testcomponent(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(testcomponents[target], split_option, line)

endfunction
"}}}
" Function: s:jump_testcontroller() {{{
" ============================================================
function! s:jump_testcontroller(...)

  let split_option = a:1
  let target = ''
  let testcontrollers = s:get_testcontrollers()

  if a:0 >= 2
    " Controller name is specified in the argument.
    let target = a:2
  else
    " Controller name is inferred from the currently opened controllers file.
    let path = expand("%:p")

    if s:is_controller(path)
      let target = s:path_to_name_controller(path)
    else
      return
    endif
  endif

  if !has_key(testcontrollers, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_testcontroller(target))
      let testcontrollers[target] = s:name_to_path_testcontroller(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(testcontrollers[target], split_option, line)

endfunction
"}}}
" Function: s:jump_testhelper() {{{
" ============================================================
function! s:jump_testhelper(...)

  let split_option = a:1
  let target = ''
  let testhelpers = s:get_testhelpers()

  if a:0 >= 2
    " Helper name is specified in the argument.
    let target = a:2
  else
    " Helper name is inferred from the currently opened helper file.
    let path = expand("%:p")

    if s:is_helper(path)
      let target = s:path_to_name(path)
    else
      return
    endif
  endif

  if !has_key(testhelpers, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_testhelper(target))
      let testhelpers[target] = s:name_to_path_testhelper(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(testhelpers[target], split_option, line)

endfunction
"}}}
" Function: s:jump_test() {{{
" ============================================================
function! s:jump_test(...)

  let split_option = a:1
  let path = expand("%:p")

  if s:is_component(path)
    " -> testcomponent
    let target = s:path_to_name(path)
    call s:jump_testcomponent(a:1, target)

  elseif s:is_controller(path)
    " -> testcontroller
    let target = s:path_to_name_controller(path)
    call s:jump_testcontroller(a:1, target)

  elseif s:is_behavior(path)
    " -> testbehavior
    let target = s:path_to_name(path)
    call s:jump_testbehavior(a:1, target)

  elseif s:is_model(path)
    " -> testmodel
    let target = s:path_to_name_model(path)
    call s:jump_testmodel(a:1, target)

  elseif s:is_fixture(path)
    " -> testmodel
    let target = s:path_to_name_fixture(path)
    call s:jump_testmodel(a:1, target)

  elseif s:is_helper(path)
    " -> testhelper
    let target = s:path_to_name(path)
    call s:jump_testhelper(a:1, target)
  else
    return
  endif

endfunction
"}}}
" Function: s:jump_fixture() {{{
" ============================================================
function! s:jump_fixture(...)

  let split_option = a:1
  let target = ''
  let fixtures = s:get_fixtures()

  if a:0 >= 2
    " fixture name is specified in the argument.
    let target = a:2
  else
    " fixture name is inferred from the currently opened model file.
    let path = expand("%:p")

    if s:is_model(path)
      let target = s:path_to_name_model(path)
    elseif s:is_testmodel(path)
      let target = s:path_to_name_test(path)
    else
      return
    endif
  endif

  if !has_key(fixtures, target)
    " If the file does not exist, ask whether to create a new file.
    if s:confirm_create_file(s:name_to_path_fixture(target))
      let fixtures[target] = s:name_to_path_fixture(target)
    else
      call s:echo_warning(target . " is not found.")
      return
    endif
  endif

  let line = 0
  call s:open_file(fixtures[target], split_option, line)

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

" Functions: s:path_to_name_xxx() {{{
" ============================================================
function! s:path_to_name(path)
  return fnamemodify(a:path, ":t:r")
endfunction

function! s:path_to_name_controller(path)
  return substitute(fnamemodify(a:path, ":t:r"), "_controller$", "", "")
endfunction

function! s:path_to_name_model(path)
  return substitute(fnamemodify(a:path, ":t:r"), "_model$", "", "")
endfunction

function! s:path_to_name_theme(path)
  return fnamemodify(a:path, ":p:h:t")
endfunction

function! s:path_to_name_test(path)
  return substitute(fnamemodify(a:path, ":t:r"), ".test$", "", "")
endfunction

function! s:path_to_name_testcontroller(path)
  return substitute(fnamemodify(a:path, ":t:r"), "_controller.test$", "", "")
endfunction

function! s:path_to_name_fixture(path)
  return substitute(fnamemodify(a:path, ":t:r"), "_fixture$", "", "")
endfunction
" }}}

" Functions: s:name_to_path_xxx() {{{
" ============================================================
function! s:name_to_path_controller(name)
  return s:paths.controllers . a:name . "_controller.php"
endfunction

function! s:name_to_path_model(name)
  return s:paths.models . a:name . ".php"
endfunction

function! s:name_to_path_config(name)
  return s:paths.configs . a:name . ".php"
endfunction

function! s:name_to_path_component(name)
  return s:paths.components . a:name . ".php"
endfunction

function! s:name_to_path_shell(name)
  return s:paths.shells . a:name . ".php"
endfunction

function! s:name_to_path_task(name)
  return s:paths.tasks . a:name . ".php"
endfunction

function! s:name_to_path_behavior(name)
  return s:paths.behaviors . a:name . ".php"
endfunction

function! s:name_to_path_helper(name)
  return s:paths.helpers . a:name . ".php"
endfunction

function! s:name_to_path_testmodel(name)
  return s:paths.testmodels . a:name . ".test.php"
endfunction

function! s:name_to_path_testbehavior(name)
  return s:paths.testbehaviors . a:name . ".test.php"
endfunction

function! s:name_to_path_testcomponent(name)
  return s:paths.testcomponents . a:name . ".test.php"
endfunction

function! s:name_to_path_testcontroller(name)
  return s:paths.testcontrollers . a:name . "_controller.test.php"
endfunction

function! s:name_to_path_testhelper(name)
  return s:paths.testhelpers . a:name . ".test.php"
endfunction

function! s:name_to_path_fixture(name)
  return s:paths.fixtures. a:name . "_fixture.php"
endfunction
" }}}

" Functions: s:is_xxx() {{{
" ============================================================
function! s:is_view(path)
  if filereadable(a:path) && match(a:path, s:paths.views) != -1 && fnamemodify(a:path, ":e") == "ctp"
    return 1
  endif
  return 0
endfunction

function! s:is_model(path)
  if filereadable(a:path) && match(a:path, s:paths.models) != -1 && fnamemodify(a:path, ":e") == "php"
    return 1
  endif
  return 0
endfunction

function! s:is_controller(path)
  if filereadable(a:path) && match(a:path, s:paths.controllers) != -1 && match(a:path, "_controller\.php$") != -1
    return 1
  endif
  return 0
endfunction

function! s:is_component(path)
  if filereadable(a:path) && match(a:path, s:paths.components) != -1 && fnamemodify(a:path, ":e") == "php"
    return 1
  endif
  return 0
endfunction

function! s:is_behavior(path)
  if filereadable(a:path) && match(a:path, s:paths.behaviors) != -1 && fnamemodify(a:path, ":e") == "php"
    return 1
  endif
  return 0
endfunction

function! s:is_helper(path)
  if filereadable(a:path) && match(a:path, s:paths.helpers) != -1 && fnamemodify(a:path, ":e") == "php"
    return 1
  endif
  return 0
endfunction

function! s:is_testmodel(path)
  if filereadable(a:path) && match(a:path, s:paths.testmodels) != -1 && match(a:path, "\.test\.php$") != -1
    return 1
  endif
  return 0
endfunction

function! s:is_testbehavior(path)
  if filereadable(a:path) && match(a:path, s:paths.testbehaviors) != -1 && match(a:path, "\.test\.php$") != -1
    return 1
  endif
  return 0
endfunction

function! s:is_testcomponent(path)
  if filereadable(a:path) && match(a:path, s:paths.testcomponents) != -1 && match(a:path, "\.test\.php$") != -1
    return 1
  endif
  return 0
endfunction

function! s:is_testcontroller(path)
  if filereadable(a:path) && match(a:path, s:paths.testcontrollers) != -1 && match(a:path, "_controller\.test\.php$") != -1
    return 1
  endif
  return 0
endfunction

function! s:is_testhelper(path)
  if filereadable(a:path) && match(a:path, s:paths.testhelpers) != -1 && match(a:path, "\.test\.php$") != -1
    return 1
  endif
  return 0
endfunction

function! s:is_fixture(path)
  if filereadable(a:path) && match(a:path, s:paths.fixtures) != -1 && match(a:path, "_fixture\.php$") != -1
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


" Function: s:get_complelist() {{{
" ============================================================
function! s:get_complelist(dict,ArgLead)
  let list = sort(keys(a:dict))
  return filter(list, 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction
" }}}
" Function: s:get_complelist_controller() {{{
" ============================================================
function! s:get_complelist_controller(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_controllers(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_model() {{{
" ============================================================
function! s:get_complelist_model(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_models(), a:ArgLead)
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
  return s:get_complelist(s:get_configs(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_component() {{{
" ============================================================
function! s:get_complelist_component(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_components(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_shell() {{{
" ============================================================
function! s:get_complelist_shell(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_shells(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_task() {{{
" ============================================================
function! s:get_complelist_task(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_tasks(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_behavior() {{{
" ============================================================
function! s:get_complelist_behavior(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_behaviors(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_helper() {{{
" ============================================================
function! s:get_complelist_helper(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_helpers(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_testmodel() {{{
" ============================================================
function! s:get_complelist_testmodel(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_testmodels(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_testbehavior() {{{
" ============================================================
function! s:get_complelist_testbehavior(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_testbehaviors(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_testcomponent() {{{
" ============================================================
function! s:get_complelist_testcomponent(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_testcomponents(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_testcontroller() {{{
" ============================================================
function! s:get_complelist_testcontroller(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_testcontrollers(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_testhelper() {{{
" ============================================================
function! s:get_complelist_testhelper(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_testhelpers(), a:ArgLead)
endfunction
" }}}
" Function: s:get_complelist_log() {{{
" ============================================================
function! s:get_complelist_log(ArgLead, CmdLine, CursorPos)
  let list = sort(keys(g:cakephp_log))
  return filter(sort(list), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction
" }}}
" Function: s:get_complelist_fixture() {{{
" ============================================================
function! s:get_complelist_fixture(ArgLead, CmdLine, CursorPos)
  return s:get_complelist(s:get_fixtures(), a:ArgLead)
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
command! -n=? -complete=customlist,s:get_complelist_component Ccomponent call s:jump_component('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_component Ccomponentsp call s:jump_component('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_component Ccomponentvsp call s:jump_component('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_component Ccomponenttab call s:jump_component('t', <f-args>)

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

" * -> Behavior
" Argument is Behavior.
command! -n=? -complete=customlist,s:get_complelist_behavior Cbehavior call s:jump_behavior('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_behavior Cbehaviorsp call s:jump_behavior('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_behavior Cbehaviorvsp call s:jump_behavior('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_behavior Cbehaviortab call s:jump_behavior('t', <f-args>)

" * -> Helper
" Argument is Helper.
command! -n=? -complete=customlist,s:get_complelist_helper Chelper call s:jump_helper('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_helper Chelpersp call s:jump_helper('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_helper Chelpervsp call s:jump_helper('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_helper Chelpertab call s:jump_helper('t', <f-args>)

" * -> Test of Model
" Argument is Test of Model.
command! -n=? -complete=customlist,s:get_complelist_testmodel Ctestmodel call s:jump_testmodel('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testmodel Ctestmodelsp call s:jump_testmodel('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testmodel Ctestmodelvsp call s:jump_testmodel('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testmodel Ctestmodeltab call s:jump_testmodel('t', <f-args>)

" * -> Test of Behavior
" Argument is Test of Behavior.
command! -n=? -complete=customlist,s:get_complelist_testbehavior Ctestbehavior call s:jump_testbehavior('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testbehavior Ctestbehaviorsp call s:jump_testbehavior('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testbehavior Ctestbehaviorvsp call s:jump_testbehavior('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testbehavior Ctestbehaviortab call s:jump_testbehavior('t', <f-args>)

" * -> Test of Component
" Argument is Test of Component.
command! -n=? -complete=customlist,s:get_complelist_testcomponent Ctestcomponent call s:jump_testcomponent('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testcomponent Ctestcomponentsp call s:jump_testcomponent('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testcomponent Ctestcomponentvsp call s:jump_testcomponent('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testcomponent Ctestcomponenttab call s:jump_testcomponent('t', <f-args>)

" * -> Test of Controller
" Argument is Test of Controller.
command! -n=? -complete=customlist,s:get_complelist_testcontroller Ctestcontroller call s:jump_testcontroller('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testcontroller Ctestcontrollersp call s:jump_testcontroller('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testcontroller Ctestcontrollervsp call s:jump_testcontroller('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testcontroller Ctestcontrollertab call s:jump_testcontroller('t', <f-args>)

" * -> Test of Helper
" Argument is Test of Helper.
command! -n=? -complete=customlist,s:get_complelist_testhelper Ctesthelper call s:jump_testhelper('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testhelper Ctesthelpersp call s:jump_testhelper('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testhelper Ctesthelpervsp call s:jump_testhelper('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_testhelper Ctesthelpertab call s:jump_testhelper('t', <f-args>)

" * -> Test of any
command! -n=0  Ctest call s:jump_test('n', <f-args>)
command! -n=0  Ctestsp call s:jump_test('s', <f-args>)
command! -n=0  Ctestvsp call s:jump_test('v', <f-args>)
command! -n=0  Ctesttab call s:jump_test('t', <f-args>)

" * -> Fixture
" Argument is Fixture.
command! -n=? -complete=customlist,s:get_complelist_fixture Cfixture call s:jump_fixture('n', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_fixture Cfixturesp call s:jump_fixture('s', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_fixture Cfixturevsp call s:jump_fixture('v', <f-args>)
command! -n=? -complete=customlist,s:get_complelist_fixture Cfixturetab call s:jump_fixture('t', <f-args>)

" * -> Log
" Argument is Log name.
command! -n=1 -complete=customlist,s:get_complelist_log Clog call s:tail_log(<f-args>)
" }}}

" SECTION: Unite Sources {{{
" ============================================================
if exists('g:loaded_unite')

  " unite-cake_controller {{{
    let s:unite_source_controller = {
          \ 'name' : 'cake_controller',
          \ 'description' : 'CakePHP Controllers',
          \ }
    call unite#define_source(s:unite_source_controller)

    function! s:unite_source_controller.gather_candidates(args, context)
      let candidates = []
      for i in items(s:get_controllers())
        call add(candidates, {
              \ 'word' : i[0],
              \ 'kind' : 'file',
              \ 'source' : 'cake_controller',
              \ 'action__path' : i[1],
              \ 'action__directory' : fnamemodify(i[1],":p:h"),
              \ })
      endfor

      return candidates
    endfunction
  " }}}
  " unite-cake_model {{{
    let s:unite_source_model = {
          \ 'name' : 'cake_model',
          \ 'description' : 'CakePHP Models',
          \ }
    call unite#define_source(s:unite_source_model)

    function! s:unite_source_model.gather_candidates(args, context)
      let candidates = []
      for i in items(s:get_models())
        call add(candidates, {
              \ 'word' : i[0],
              \ 'kind' : 'file',
              \ 'source' : 'cake_model',
              \ 'action__path' : i[1],
              \ 'action__directory' : fnamemodify(i[1],":p:h"),
              \ })
      endfor

      return candidates
    endfunction
  " }}}
  " unite-cake_view {{{
    let s:unite_source_view = {
          \ 'name' : 'cake_view',
          \ 'description' : 'CakePHP Views',
          \ 'hooks' : {},
          \ }
    call unite#define_source(s:unite_source_view)

    function! s:unite_source_view.gather_candidates(args, context)
      let candidates = []

      if len(a:context.source__controllers) == 0
        call s:echo_warning("No controller in current buffer. [Usage] :Unite cake_view:{controller-name},{controller-name}...")
        return candidates
      endif

      for i in a:context.source__controllers
        " default
        for path in split(globpath(s:paths.views . i . "/", "*.ctp"), "\n")
          call add(candidates, {
                \ 'word' : '(No Theme) ' . s:path_to_name(path),
                \ 'kind' : 'file',
                \ 'source' : 'cake_view',
                \ 'action__path' : path,
                \ 'action__directory' : fnamemodify(path,":p:h"),
                \ })
        endfor

        " every theme
        for theme in items(s:get_themes())
          for path in split(globpath(theme[1] . i . "/", "*.ctp"), "\n")
            call add(candidates, {
                  \ 'word' : '(' . theme[0] . ') ' . s:path_to_name(path),
                  \ 'kind' : 'file',
                  \ 'source' : 'cake_view',
                  \ 'action__path' : path,
                  \ 'action__directory' : fnamemodify(path,":p:h"),
                  \ })
          endfor
        endfor
      endfor

      return candidates
    endfunction

    function! s:unite_source_view.hooks.on_init(args, context)
      " get controller's list
      let controllers = []

      if len(a:args) == 0
        if s:is_controller(expand("%:p"))
          call add(controllers, s:path_to_name_controller(expand("%:p")))
        endif
      else
        for i in split(a:args[0], ",")
          if s:is_controller(s:name_to_path_controller(i))
            call add(controllers, i)
          elseif s:is_controller(s:name_to_path_controller(s:pluralize(i)))
            " try the plural form.
            call add(controllers, s:pluralize(i))
          endif
        endfor
      endif

      let a:context.source__controllers = controllers

    endfunction
  " }}}
" unite-cake_behavior {{{
  let s:unite_source_behavior = {
        \ 'name' : 'cake_behavior',
        \ 'description' : 'CakePHP Behaviors',
        \ }
  call unite#define_source(s:unite_source_behavior)

  function! s:unite_source_behavior.gather_candidates(args, context)
    let candidates = []
    for i in items(s:get_behaviors())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_behavior',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor

    return candidates
  endfunction
" }}}
" unite-cake_helper {{{
  let s:unite_source_helper = {
        \ 'name' : 'cake_helper',
        \ 'description' : 'CakePHP Helpers',
        \ }
  call unite#define_source(s:unite_source_helper)

  function! s:unite_source_helper.gather_candidates(args, context)
    let candidates = []
    for i in items(s:get_helpers())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_helper',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor

    return candidates
  endfunction
" }}}
" unite-cake_component {{{
  let s:unite_source_component = {
        \ 'name' : 'cake_component',
        \ 'description' : 'CakePHP Components',
        \ }
  call unite#define_source(s:unite_source_component)

  function! s:unite_source_component.gather_candidates(args, context)
    let candidates = []
    for i in items(s:get_components())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_component',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor

    return candidates
  endfunction
" }}}
" unite-cake_fixture {{{
  let s:unite_source_fixture = {
        \ 'name' : 'cake_fixture',
        \ 'description' : 'CakePHP Fixtures',
        \ }
  call unite#define_source(s:unite_source_fixture)

  function! s:unite_source_fixture.gather_candidates(args, context)
    let candidates = []
    for i in items(s:get_fixtures())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_fixture',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor

    return candidates
  endfunction
" }}}
" unite-cake_config {{{
  let s:unite_source_config = {
        \ 'name' : 'cake_config',
        \ 'description' : 'CakePHP Configs',
        \ }
  call unite#define_source(s:unite_source_config)

  function! s:unite_source_config.gather_candidates(args, context)
    let candidates = []
    for i in items(s:get_configs())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_config',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor

    return candidates
  endfunction
" }}}
" unite-cake_shell {{{
  let s:unite_source_shell = {
        \ 'name' : 'cake_shell',
        \ 'description' : 'CakePHP Shells',
        \ }
  call unite#define_source(s:unite_source_shell)

  function! s:unite_source_shell.gather_candidates(args, context)
    let candidates = []
    for i in items(s:get_shells())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_shell',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor

    return candidates
  endfunction
" }}}
" unite-cake_task {{{
  let s:unite_source_task = {
        \ 'name' : 'cake_task',
        \ 'description' : 'CakePHP Tasks',
        \ }
  call unite#define_source(s:unite_source_task)

  function! s:unite_source_task.gather_candidates(args, context)
    let candidates = []
    for i in items(s:get_tasks())
      call add(candidates, {
            \ 'word' : i[0],
            \ 'kind' : 'file',
            \ 'source' : 'cake_task',
            \ 'action__path' : i[1],
            \ 'action__directory' : fnamemodify(i[1],":p:h"),
            \ })
    endfor

    return candidates
  endfunction
" }}}

endif
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
