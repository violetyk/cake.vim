" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.

let s:save_cpo = &cpo
set cpo&vim


" SECTION: Script Variables {{{
" ============================================================
let s:cache_last_app_path = ''
let s:is_initialized = 0
" }}}

function! cake#initialize(path) " {{{

  let a:path_app = ''

  " set app directory of the project.
  if a:path != ''
    let a:path_app = fnamemodify(a:path, ":p")
  elseif exists("g:cakephp_app") && g:cakephp_app != ''
    let a:path_app = g:cakephp_app
  endif

  " call factory method
  if cake#is_cake20(a:path_app)
    let g:cake = cake#cake20#factory(a:path_app)
    let s:is_initialized = 1
    call cake#map_commands()
  elseif cake#is_cake13(a:path_app)
    let g:cake = cake#cake13#factory(a:path_app)
    let s:is_initialized = 1
    call cake#map_commands()
  else
    call cake#util#echo_warning("[cake.vim] Please set an application directory of CakePHP.")
    let s:is_initialized = 0
    return
  endif

  call g:cake.set_log(g:cakephp_log)

endfunction " }}}
function! cake#autoset_app() "{{{

  " find Config/core.php
  let app_config_path  = finddir('Config', escape(expand("%:p:h"), ' \') . ';')
  if app_config_path != '' && filereadable(app_config_path . '/core.php')
    let app_path = fnamemodify(app_config_path, ":h")
    call cake#initialize(app_path)
    let s:cache_last_app_path = app_path
    return
  endif

  " find config/core.php
  let app_config_path  = finddir('config', escape(expand("%:p:h"), ' \') . ';')
  if app_config_path != '' && filereadable(app_config_path . '/core.php')
    let app_path = fnamemodify(app_config_path, ":h")
    call cake#initialize(app_path)
    let s:cache_last_app_path = app_path
    return
  endif

  " retry
  if s:cache_last_app_path != '' && isdirectory(s:cache_last_app_path)
    call cake#initialize(s:cache_last_app_path)
  endif
endfunction "}}}
function! cake#map_commands() "{{{
  if s:is_initialized == 0
    return
  endif

  nnoremap <buffer> <silent> <Plug>CakeJump       :<C-u>call cake#smart_jump('n')<CR>
  nnoremap <buffer> <silent> <Plug>CakeSplitJump  :<C-u>call cake#smart_jump('s')<CR>
  nnoremap <buffer> <silent> <Plug>CakeVSplitJump :<C-u>call cake#smart_jump('v')<CR>
  nnoremap <buffer> <silent> <Plug>CakeTabJump    :<C-u>call cake#smart_jump('t')<CR>
  if !hasmapto('<Plug>CakeJump')
    nmap <buffer> gf <Plug>CakeJump
  endif
  if !hasmapto('<Plug>CakeSplitJump')
    nmap <buffer> <C-w>f <Plug>CakeSplitJump
  endif
  if !hasmapto('<Plug>CakeVSplitJump')
    exe 'nmap <buffer> ' . g:cakephp_keybind_vsplit_gf . ' <Plug>CakeVSplitJump'
  endif
  if !hasmapto('<Plug>CakeTabJump')
    nmap <buffer> <C-w>gf <Plug>CakeTabJump
  endif

endfunction "}}}
function! cake#smart_jump(option) "{{{
  call g:cake.smart_jump(a:option)
endfunction "}}}

function! cake#is_cake13(path) "{{{
  let l:path = fnamemodify(a:path, ":p")
  if isdirectory(l:path. 'controllers') && isdirectory(l:path . 'models') && isdirectory(l:path . 'views')
    return 1
  endif
  return 0
endfunction " }}}
function! cake#is_cake20(path) " {{{
  let l:path = fnamemodify(a:path, ":p")
  if isdirectory(l:path. 'Controller') && isdirectory(l:path . 'Model') && isdirectory(l:path . 'View')
    return 1
  endif
  return 0
endfunction " }}}


" Functions: get_complelist_xxx()
" ============================================================
function! cake#get_complelist(dict,ArgLead) "{{{
  let list = sort(keys(a:dict))
  return filter(list, 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction "}}}
function! cake#get_complelist_lib(ArgLead, CmdLine, CursorPos) "{{{
  try
    let list = cake#get_complelist(g:cake.get_libs(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_controller(ArgLead, CmdLine, CursorPos) "{{{
  try
    let list = cake#get_complelist(g:cake.get_controllers(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_model(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_models(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_view(ArgLead, CmdLine, CursorPos) "{{{
  try
    let args = split(a:CmdLine, '\W\+')
    let view_name = get(args, 1)
    let theme_name = get(args, 2)

    if !g:cake.is_controller(expand("%:p"))
      return []
    else
      let controller_name = g:cake.path_to_name_controller(expand('%:p'))
      let views = keys(g:cake.get_views(controller_name))

      " get list of View name.
      if count(views, view_name) == 0
        return filter(sort(views), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
      else
        " View name is ok. Next, get list of Theme name.
        let themes = g:cake.get_themes()
        if !has_key(themes, theme_name)
          return filter(sort(keys(themes)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
        endif
      endif

    endif

  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_controllerview(ArgLead, CmdLine, CursorPos) "{{{
  try
    let args = split(a:CmdLine, '\W\+')
    let controller_name = cake#util#camelize(get(args, 1))
    let view_name = get(args, 2)
    let theme_name = get(args, 3)
    let controllers = g:cake.get_controllers()
    let themes = g:cake.get_themes()

    if !has_key(controllers, controller_name)
      " Completion of the first argument.
      " Returns a list of the controller name.
      return cake#get_complelist_controller(a:ArgLead, a:CmdLine, a:CursorPos)
    elseif count(keys(g:cake.get_views(controller_name)), view_name) == 0
      " Completion of the second argument.
      " Returns a list of view names.
      " The view corresponds to the first argument specified in the controller.
      return filter(sort(keys(g:cake.get_views(controller_name))), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
    elseif !has_key(themes, theme_name)
      " Completion of the third argument.
      " Returns a list of theme names.
      return filter(sort(keys(themes)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
    endif
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_config(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_configs(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_component(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_components(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_shell(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_shells(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_task(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_tasks(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_behavior(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_behaviors(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_helper(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_helpers(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_testmodel(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_testmodels(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_testbehavior(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_testbehaviors(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_testcomponent(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_testcomponents(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_testcontroller(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_testcontrollers(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_testhelper(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = cake#get_complelist(g:cake.get_testhelpers(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_fixture(ArgLead, CmdLine, CursorPos) "{{{
  try
    let list = cake#get_complelist(g:cake.get_fixtures(), a:ArgLead)
    return list
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
function! cake#get_complelist_log(ArgLead, CmdLine, CursorPos) " {{{
  try
    let list = sort(keys(g:cakephp_log))
    return filter(sort(list), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  catch
    call cake#util#echo_warning("[cake.vim] An application directory is not set. Please :Cakephp {app}.")
  endtry
endfunction " }}}
" ============================================================


function! cake#factory(path_app)

  let self = {}
  let self.paths = {}
  let self.vars = {}

  " Functions: abstract methods.(These implement it in a subclass.) {{{
  " ============================================================
  function! self.get_libs()
  endfunction
  function! self.get_controllers()
  endfunction
  function! self.get_models()
  endfunction
  function! self.get_views()
  endfunction

  function! self.path_to_name_controller(path)
  endfunction
  function! self.path_to_name_component(path)
  endfunction
  function! self.path_to_name_model(path)
  endfunction
  function! self.path_to_name_testcontroller(path)
  endfunction
  function! self.path_to_name_testmodel(path)
  endfunction
  function! self.path_to_name_testcomponent(path)
  endfunction
  function! self.path_to_name_testhelper(path)
  endfunction
  function! self.path_to_name_testbehavior(path)
  endfunction
  function! self.path_to_name_fixture(path)
  endfunction
  function! self.path_to_name_shell(path)
  endfunction
  function! self.path_to_name_task(path)
  endfunction
  function! self.path_to_name_behavior(path)
  endfunction
  function! self.path_to_name_helper(path)
  endfunction
  function! self.path_to_name_theme(path)
  endfunction

  function! self.name_to_path_controller(name)
  endfunction
  function! self.name_to_path_model(name)
  endfunction
  function! self.name_to_path_component(name)
  endfunction
  function! self.name_to_path_component(name)
  endfunction
  function! self.name_to_path_shell(name)
  endfunction
  function! self.name_to_path_task(name)
  endfunction
  function! self.name_to_path_behavior(name)
  endfunction
  function! self.name_to_path_helper(name)
  endfunction
  function! self.name_to_path_testmodel(name)
  endfunction
  function! self.name_to_path_testbehavior(name)
  endfunction
  function! self.name_to_path_testcomponent(name)
  endfunction
  function! self.name_to_path_testcontroller(name)
  endfunction
  function! self.name_to_path_testhelper(name)
  endfunction
  function! self.name_to_path_fixture(name)
  endfunction
  function! self.name_to_path_view(controller_name, view_name, theme_name)
  endfunction

  function! self.is_controller(path)
  endfunction
  function! self.is_model(path)
  endfunction
  function! self.is_view(path)
  endfunction
  function! self.is_testcontroller(path)
  endfunction
  function! self.is_testmodel(path)
  endfunction
  function! self.is_fixture(path)
  endfunction
  function! self.is_testcomponent(path)
  endfunction
  function! self.is_behavior(path)
  endfunction
  function! self.is_helper(path)
  endfunction
  function! self.is_testbehavior(path)
  endfunction
  function! self.is_testcomponent(path)
  endfunction
  function! self.is_testhelper(path)
  endfunction
  function! self.is_shell(path)
  endfunction
  function! self.is_task(path)
  endfunction
  " }}}

  " Functions: get_dictionary()
  " [object_name : path]
  " ============================================================
  function! self.get_behaviors() "{{{
    let behaviors = {}

    for path in split(globpath(self.paths.behaviors, "*.php"), "\n")
      let name = self.path_to_name_behavior(path)
      let behaviors[name] = path
    endfor

    for build_path in self.get_build_paths('behaviors')
      for path in split(globpath(build_path, "*.php"), "\n")
        let name = self.path_to_name_behavior(path)
        if !has_key(behaviors, name)
          let behaviors[name] = path
        endif
      endfor
    endfor


    return behaviors
  endfunction " }}}
  function! self.get_components() "{{{
    let components = {}

    for path in split(globpath(self.paths.components, "*.php"), "\n")
      let name = self.path_to_name_component(path)
      let components[name] = path
    endfor

    for build_path in self.get_build_paths('components')
      for path in split(globpath(build_path, "*.php"), "\n")
        let name = self.path_to_name_component(path)
        if !has_key(components, name)
          let components[name] = path
        endif
      endfor
    endfor

    return components
  endfunction "}}}
  function! self.get_helpers() "{{{
    let helpers = {}

    for path in split(globpath(self.paths.helpers, "*.php"), "\n")
      let name = self.path_to_name_helper(path)
      let helpers[name] = path
    endfor

    for build_path in self.get_build_paths('helpers')
      for path in split(globpath(build_path, "*.php"), "\n")
        let name = self.path_to_name_helper(path)
        if !has_key(helpers, name)
          let helpsers[name] = path
        endif
      endfor
    endfor

    return helpers
  endfunction " }}}
  function! self.get_shells() "{{{
    let shells = {}

    for path in split(globpath(self.paths.shells, "*.php"), "\n")
      let name = self.path_to_name_shell(path)
      let shells[name] = path
    endfor

    return shells
  endfunction " }}}
    function! self.get_tasks() "{{{
      let tasks = {}

      for path in split(globpath(self.paths.tasks, "*.php"), "\n")
        let name = self.path_to_name_task(path)
        let tasks[name] = path
      endfor

      return tasks
    endfunction " }}}
  function! self.get_fixtures() "{{{
    let fixtures = {}

    for path in split(globpath(self.paths.fixtures, "*.php"), "\n")
      let name = self.path_to_name_fixture(path)
      let fixtures[name] = path
    endfor

    return fixtures
  endfunction " }}}
  function! self.get_testmodels() "{{{
    let testmodels = {}

    for path in split(globpath(self.paths.testmodels, "*.php"), "\n")
      let name = self.path_to_name_testmodel(path)
      let testmodels[name] = path
    endfor

    return testmodels
  endfunction
  " }}}
  function! self.get_testbehaviors() "{{{
    let testbehaviors = {}

    for path in split(globpath(self.paths.testbehaviors, "*.php"), "\n")
      let name = self.path_to_name_testbehavior(path)
      let testbehaviors[name] = path
    endfor

    return testbehaviors
  endfunction " }}}
  function! self.get_testcomponents() "{{{
    let testcomponents = {}

    for path in split(globpath(self.paths.testcomponents, "*.php"), "\n")
      let name = self.path_to_name_testcomponent(path)
      let testcomponents[name] = path
    endfor

    return testcomponents
  endfunction " }}}
  function! self.get_testcontrollers() "{{{
    let testcontrollers = {}

    for path in split(globpath(self.paths.testcontrollers, "*.php"), "\n")
      let name = self.path_to_name_testcontroller(path)
      let testcontrollers[name] = path
    endfor

    return testcontrollers
  endfunction " }}}
  function! self.get_testhelpers() "{{{
    let testhelpers = {}

    for path in split(globpath(self.paths.testhelpers, "*.php"), "\n")
      let name = self.path_to_name_testhelper(path)
      let testhelpers[name] = path
    endfor

    return testhelpers
  endfunction " }}}
  function! self.get_themes() "{{{

    let themes = {}

    for path in split(globpath(self.paths.themes, "*/"), "\n")
      let name = self.path_to_name_theme(path)
      let themes[name] = path
    endfor

    return themes

  endfunction "}}}
  function! self.get_configs() "{{{

    let configs = {}

    for path in split(globpath(self.paths.configs, "*.php"), "\n")
      let name = fnamemodify(path, ":t:r")
      let configs[name] = path
    endfor

    return configs

  endfunction "}}}
  " ============================================================

  " Functions: jump_xxx()
  " ============================================================
  function! self.jump_controller(...) "{{{

    let split_option = a:1
    " let target = ''
    let targets = []
    let action_name = ''
    let controllers = self.get_controllers()

    if a:0 >= 2
      " Controller name is specified in the argument.
      " let target = a:2
      let targets = self.args_to_targets(a:000)
    else
      " Controller name is inferred from the currently opened file (view or model or testcontroller).
      let path = expand("%:p")

      if self.is_view(path)

        if self.in_theme(path)
          let pattern = '\(' . self.paths.themes . self.get_viewtheme(path) . '/\)\zs\w\+\ze'
        else
          let pattern = '\(' . self.paths.views . '\)\zs\w\+\ze'
        endif
        echo pattern

        let target = matchstr(path, pattern)
        call add(targets, target)

        let action_name = expand("%:p:t:r")
      elseif self.is_model(path)
        call add(targets, cake#util#pluralize(self.path_to_name_model(path)))
      elseif self.is_testcontroller(path)
        call add(targets, self.path_to_name_testcontroller(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(controllers, target)

        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_controller(target))
          let controllers[target] = self.name_to_path_controller(target)
        else
          call cake#util#echo_warning(target . "Controller is not found.")
          return
        endif
      endif

      " Jump to the line that corresponds to the view's function.
      let line = self.get_line_in_controller(target, action_name)

      call cake#util#open_file(controllers[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_model(...) "{{{

    let split_option = a:1
    let targets = []
    let models = self.get_models()

    if a:0 >= 2
      " Model name is specified in the argument.
      let targets = self.args_to_targets(a:000)
    else
      " Model name is inferred from the currently opened controller file.
      let path = expand("%:p")

      if self.is_controller(path)
        " let target = cake#util#singularize(substitute(cake#util#camelize(expand("%:p:t:r")), "Controller$", "", ""))
        call add(targets, cake#util#singularize(substitute(cake#util#camelize(expand("%:p:t:r")), "Controller$", "", "")))
      elseif self.is_testmodel(path);
        " let target = self.path_to_name_testmodel(path)
        call add(targets, self.path_to_name_testmodel(path))
      elseif self.is_fixture(path)
        " let target = self.path_to_name_fixture(path)
        call add(targets, self.path_to_name_fixture(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(models, target)

        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_model(target))
          let models[target] = self.name_to_path_model(target)
        else
          call cake#util#echo_warning(target . "Model is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(models[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_view(...) " {{{
    let views = []

    if !self.is_controller(expand("%:p"))
      call cake#util#echo_warning("No Controller in current buffer.")
      return
    endif

    let split_option = a:1
    let controller_name = self.path_to_name_controller(expand('%:p'))

    " determine view
    if exists('a:2')
      let view_name = a:2
      if match(view_name, '/') > 0
        let view_name = view_name[strridx(view_name, '/')+1:]
      endif
    else
      let neighbor_line = 0
      let func_line = self.get_views(controller_name)
      let current_line = line(".")
      for l in cake#util#nrsort(values(func_line))
        if l <= current_line
          let neighbor_line = l
          break
        endif
      endfor

      if neighbor_line == 0
        return
      endif

      for [f, l] in items(func_line)
        if l == neighbor_line
          let view_name = f
          break
        endif
      endfor

    endif

    " create theme list
    if exists('a:3')
      let theme = a:3
      let themes = [theme]
    elseif exists("g:cakephp_use_theme") && strlen(g:cakephp_use_theme) > 0
      let theme = g:cakephp_use_theme
      let themes = [theme]
    else
      let theme = '' "no theme
      let themes = keys(self.get_themes())
      let themes = insert(themes, theme)
    endif

    " find paths of view.
    for theme_name in themes
      let view_dir = self.name_to_path_viewdir(controller_name, view_name, theme_name)
      for view_path in split(globpath(view_dir, '**/' . view_name . '.ctp'), "\n")
        if filereadable(view_path)
          call add(views, view_path)
        endif
      endfor
    endfor

    let i = len(views)
    if i == 0
      " If the file does not exist, ask whether to create a new file.
      let target_view_path = self.name_to_path_view(controller_name, view_name, theme)
      if !cake#util#confirm_create_file(target_view_path)
        call cake#util#echo_warning(target_view_path . " is not found.")
        return
      endif
    elseif i == 1
      let target_view_path = views[0]
    elseif i > 1
      " Choice view
      let n = 1
      let tmp_choices = []
      for str in views
        let str = n . ": " . self.abbreviate(str)
        call add(tmp_choices, str)
        let n = n + 1
      endfor
      let choices = join(tmp_choices,"\n")
      let c = confirm('Which file do you jump to?', choices, 0)
      if c > 0
        let index = c - 1
        let target_view_path = views[index]
      endif
    endif

    call cake#util#open_file(target_view_path, split_option, 0)

  endfunction "}}}
  function! self.jump_controllerview(...) " {{{

    if a:0 < 3
      return
    endif

    let split_option = a:1
    let controller_name = cake#util#camelize(a:2)
    let view_name = a:3

    if a:0 >= 4
      let theme_name = a:4
    else
      let theme_name = (exists("g:cakephp_use_theme") && g:cakephp_use_theme != '')? g:cakephp_use_theme : ''
    endif

    let view_path = self.name_to_path_view(controller_name, view_name, theme_name)

    if !filewritable(view_path)
      call cake#util#echo_warning(view_path . " is not found.")
      return
    endif

    let line = 0
    call cake#util#open_file(view_path, split_option, line)

  endfunction "}}}
  function! self.jump_config(...) " {{{

    let split_option = a:1
    let targets = self.args_to_targets(a:000)
    let configs = self.get_configs()

    for target in targets
      if !has_key(configs, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_config(target))
          let configs[target] = self.name_to_path_config(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(configs[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_component(...) "{{{

    let split_option = a:1
    let targets = []
    let components = self.get_components()

    if a:0 >= 2
      " Component name is specified in the argument.
      let targets = self.args_to_targets(a:000)
    else
      " Component name is inferred from the currently opened testcomponent file.
      let path = expand("%:p")

      if self.is_testcomponent(path)
        call add(targets, self.path_to_name_testcomponent(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(components, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_component(target))
          let components[target] = self.name_to_path_component(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(components[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_shell(...) "{{{

    let split_option = a:1
    let targets = self.args_to_targets(a:000)
    let shells = self.get_shells()

    for target in targets
      let target = cake#util#camelize(target)
      if !has_key(shells, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_shell(target))
          let shells[target] = self.name_to_path_shell(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(shells[target], split_option, line)
    endfor


  endfunction
  "}}}
  function! self.jump_task(...) "{{{

    let split_option = a:1
    let targets = self.args_to_targets(a:000)
    let tasks = self.get_tasks()

    for target in targets
      let target = cake#util#camelize(target)
      if !has_key(tasks, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_task(target))
          let tasks[target] = self.name_to_path_task(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(tasks[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_behavior(...) "{{{

    let split_option = a:1
    let targets = []
    let behaviors = self.get_behaviors()

    if a:0 >= 2
      " Behaivior name is specified in the argument.
      let targets = self.args_to_targets(a:000)
    else
      " Behaivior name is inferred from the currently opened testbehavior file.
      let path = expand("%:p")

      if self.is_testbehavior(path)
        call add(targets, self.path_to_name_testbehavior(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(behaviors, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_behavior(target))
          let behaviors[target] = self.name_to_path_behavior(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(behaviors[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_helper(...) "{{{

    let split_option = a:1
    let targets = []
    let helpers = self.get_helpers()

    if a:0 >= 2
      " Helper name is specified in the argument.
      let targets = self.args_to_targets(a:000)
    else
      " Helper name is inferred from the currently opened testhelper file.
      let path = expand("%:p")

      if self.is_testhelper(path)
        call add(targets, self.path_to_name_testhelper(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(helpers, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_helper(target))
          let helpers[target] = self.name_to_path_helper(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(helpers[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_testmodel(...) "{{{

    let split_option = a:1
    let targets = []
    let testmodels = self.get_testmodels()

    if a:0 >= 2
      " Model name is specified in the argument.
      let targets = self.args_to_targets(a:000)
    else
      " Model name is inferred from the currently opened controller file.
      let path = expand("%:p")

      if self.is_model(path)
        call add(targets, self.path_to_name_model(path))
      elseif self.is_fixture(path)
        call add(targets, self.path_to_name_fixture(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(testmodels, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_testmodel(target))
          let testmodels[target] = self.name_to_path_testmodel(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(testmodels[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_testbehavior(...) "{{{

    let split_option = a:1
    let targets = []
    let testbehaviors = self.get_testbehaviors()

    if a:0 >= 2
      " Behaivior name is specified in the argument.
      let targets = self.args_to_targets(a:000)
    else
      " Behaivior name is inferred from the currently opened behavior file.
      let path = expand("%:p")

      if self.is_behavior(path)
        call add(targets, self.path_to_name_behavior(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(testbehaviors, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_testbehavior(target))
          let testbehaviors[target] = self.name_to_path_testbehavior(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(testbehaviors[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_testcomponent(...) "{{{

    let split_option = a:1
    let targets = []
    let testcomponents = self.get_testcomponents()

    if a:0 >= 2
      " Component name is specified in the argument.
      let targets = self.args_to_targets(a:000)
    else
      " Componen tname is inferred from the currently opened component file.
      let path = expand("%:p")

      if self.is_component(path)
        call add(targets, self.path_to_name_component(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(testcomponents, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_testcomponent(target))
          let testcomponents[target] = self.name_to_path_testcomponent(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(testcomponents[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_testcontroller(...) "{{{

    let split_option = a:1
    let targets = []
    let testcontrollers = self.get_testcontrollers()

    if a:0 >= 2
      " Controller name is specified in the argument.
      let targets = self.args_to_targets(a:000)
    else
      " Controller name is inferred from the currently opened controllers file.
      let path = expand("%:p")

      if self.is_controller(path)
        call add(targets, self.path_to_name_controller(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(testcontrollers, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_testcontroller(target))
          let testcontrollers[target] = self.name_to_path_testcontroller(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(testcontrollers[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_testhelper(...) "{{{

    let split_option = a:1
    let targets = []
    let testhelpers = self.get_testhelpers()

    if a:0 >= 2
      " Helper name is specified in the argument.
      let targets = self.args_to_targets(a:000)
    else
      " Helper name is inferred from the currently opened helper file.
      let path = expand("%:p")

      if self.is_helper(path)
        call add(targets, self.path_to_name_helper(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(testhelpers, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_testhelper(target))
          let testhelpers[target] = self.name_to_path_testhelper(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(testhelpers[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.jump_test(...) "{{{

    let split_option = a:1
    let path = expand("%:p")

    if self.is_component(path)
      " -> testcomponent
      let target = self.path_to_name_component(path)
      call self.jump_testcomponent(a:1, target)

    elseif self.is_controller(path)
      " -> testcontroller
      let target = self.path_to_name_controller(path)
      call self.jump_testcontroller(a:1, target)

    elseif self.is_behavior(path)
      " -> testbehavior
      let target = self.path_to_name_behavior(path)
      call self.jump_testbehavior(a:1, target)

    elseif self.is_model(path)
      " -> testmodel
      let target = self.path_to_name_model(path)
      call self.jump_testmodel(a:1, target)

    elseif self.is_fixture(path)
      " -> testmodel
      let target = self.path_to_name_fixture(path)
      call self.jump_testmodel(a:1, target)

    elseif self.is_helper(path)
      " -> testhelper
      let target = self.path_to_name_helper(path)
      call self.jump_testhelper(a:1, target)
    else
      return
    endif

  endfunction "}}}
  function! self.jump_fixture(...) "{{{

    let split_option = a:1
    let targets = []
    let fixtures = self.get_fixtures()

    if a:0 >= 2
      " fixture name is specified in the argument.
      let targets = self.args_to_targets(a:000)
    else
      " fixture name is inferred from the currently opened model file.
      let path = expand("%:p")

      if self.is_model(path)
        call add(targets, self.path_to_name_model(path))
      elseif self.is_testmodel(path)
        call add(targets, self.path_to_name_test(path))
      else
        return
      endif
    endif

    for target in targets
      let target = cake#util#camelize(target)

      if !has_key(fixtures, target)
        " If the file does not exist, ask whether to create a new file.
        if cake#util#confirm_create_file(self.name_to_path_fixture(target))
          let fixtures[target] = self.name_to_path_fixture(target)
        else
          call cake#util#echo_warning(target . " is not found.")
          return
        endif
      endif

      let line = 0
      call cake#util#open_file(fixtures[target], split_option, line)
    endfor

  endfunction
  "}}}
  function! self.jump_lib(...) " {{{

    let split_option = a:1
    let targets = self.args_to_targets(a:000)
    let libs = self.get_libs()

    for target in targets
      if !has_key(libs, target)
        call cake#util#echo_warning(target . " is not found.")
      endif

      let line = 0
      call cake#util#open_file(libs[target], split_option, line)
    endfor

  endfunction "}}}
  function! self.describe_table(...) " {{{
    if !executable('php')
      call cake#util#echo_warning('[cake.vim] php is not executable.')
      return
    endif

    if !executable('grep')
      call cake#util#echo_warning('[cake.vim] no grep in $PATH.')
      return
    endif

    if !exists("g:loaded_dbext")
      call cake#util#echo_warning('[cake.vim] dbext.vim is not found.')
      return
    endif

    if a:0 > 0
      let target = a:1
    else
      let target = expand('<cword>')
    endif

    let models = self.get_models()

    if has_key(models, target)


      " useDbConfig
      let cmd = 'grep -E ''^\s*var\s*\$useDbConfig\s*='' ' . self.name_to_path_model(target)
      let line = system(cmd)
      let db_config = matchstr(line, '\(var\s\+\$useDbConfig\s*=\s*["'']\)\zs\w\+\ze\(["''];\)')
      if  db_config == ''
        let db_config = 'default'
      endif

      try
        let config_path = self.paths.configs . 'database.php'
        let php_code =
              \ 'require_once("' . config_path . '");' .
              \ '$ref = new ReflectionClass("DATABASE_CONFIG");
              \ $DatabaseConfig = $ref->newInstance();
              \ $config = "' . db_config . '";
              \ $con = $DatabaseConfig->$config;
              \ $user = $con["login"];
              \ $password = $con["password"];
              \ $host = $con["host"];
              \ $dbname = $con["database"];
              \ echo sprintf("{\"user\":\"%s\", \"password\":\"%s\", \"host\":\"%s\", \"dbname\":\"%s\"}", $con["login"], $con["password"], $con["host"], $con["database"]);'

        let cmd = 'php -r ''' . php_code . ''''
        let params = system(cmd)
        let p = eval(params)

        let options = 'type=' . g:cakephp_db_type . ':user=' . p.user . ':passwd=' . p.password . ':dbname=' . p.dbname . ':host=' . p.host . ':port=' . g:cakephp_db_port . ':buffer_lines=' . g:cakephp_db_buffer_lines
        call dbext#DB_setMultipleOptions(options)

        " useTable
        let cmd = 'grep -E ''^\s*var\s*\$useTable\s*='' ' . self.name_to_path_model(target)
        let line = system(cmd)
        let table = matchstr(line, '\(var\s\+\$useTable\s*=\s*["'']\)\zs\w\+\ze\(["''];\)')
        if table == ''
          let table = cake#util#pluralize(cake#util#decamelize(target))
        endif

        call dbext#DB_describeTable(table)

      catch
        call cake#util#echo_warning("[cake.vim] Can't connect to Database. Please check database.php and $useDbConfig.")
        return
      endtry

    endif
  endfunction "}}}
  function! self.smart_jump(...) "{{{
    let option = a:1
    let path = expand("%:p")
    let line = getline('.')
    let word = expand('<cword>')
    let l_word = expand('<cWORD>')
    let libs = {}

    if strlen(word) == 0
      return
    endif

    " in Controller "{{{
    if self.is_controller(path)
      let controller_name = self.path_to_name_controller(path)


      " Controller / function xxx() -> View
      let view_name = matchstr(line, '\(function\s\+\)\zs\w\+\ze\(\s*(\)')
      if strlen(view_name) > 0
        call self.jump_view(option, view_name)
        return
      endif
      " Controller / $this->render('xxx') -> View
      let view_name = matchstr(line, '\(\$this->render(\s*["'']\)\zs[0-9A-Za-z/_.-]\+\ze\(["'']\s*)\)')
      if strlen(view_name) > 0
        call self.jump_view(option, view_name)
        return
      endif

      " Controller / var $layout = 'xxx'; -> layout
      let layout_name = matchstr(line, '\(var\s\+\$layout\s*=\s*["'']\)\zs[0-9A-Za-z/_.-]\+\ze\(["''];\)' )
      if strlen(layout_name) > 0
        call self.smart_jump_layout(layout_name, option)
        return
      endif
      " Controller / $this->layout = 'xxx'; -> layout
      let layout_name = matchstr(line, '\(\$this->layout\s*=\s*["'']\)\zs[0-9A-Za-z/_.-]\+\ze\(["''];\)' )
      if strlen(layout_name) > 0
        call self.smart_jump_layout(layout_name, option)
        return
      endif

      " Controller / class HogesController extends AppController -> AppController
      let controller_name = matchstr(line, '\(class\s\+\w\+Controller\s\+extends\s\+\)\zs\w\+\ze\(Controller\)' )
      if strlen(controller_name) > 0
        let controller_name = cake#util#decamelize(controller_name)
        if self.is_controller(self.name_to_path_controller(controller_name))
          call self.jump_controller(option, controller_name)
          return
        endif
      endif


      " Controller -> Model or Behavior or Component or Helper
      if self.is_model(self.name_to_path_model(word)) || self.in_build_path_model(word)
        call self.jump_model(option, word)
        return
      elseif self.is_behavior(self.name_to_path_behavior(word)) || self.in_build_path_behavior(word)
        call self.jump_behavior(option, word)
        return
      elseif self.is_component(self.name_to_path_component(word)) || self.in_build_path_component(word)
        call self.jump_component(option, word)
        return
      elseif self.is_helper(self.name_to_path_helper(word)) || self.in_build_path_helper(word)
        call self.jump_helper(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif

      " jump to Core Libraries
      if len(libs) == 0
        let libs = self.get_libs()
      endif
      let priority_order = ['', 'Behavior', 'Component', 'Helper']
      for suffix in priority_order
        let target = word . suffix
        if has_key(libs, target)
          call self.jump_lib(option, target)
          return
        endif
      endfor


    endif
    "}}}
    " in Model "{{{
    if self.is_model(path)

      " Model / class Hoge extends AppModel  -> AppModel
      let model_name = matchstr(line, '\(class\s\w\+\sextends\s\)\zs\w\+\ze\(Model\)' )
      if strlen(model_name) > 0
        let model_name = cake#util#decamelize(model_name)
        if self.is_model(self.name_to_path_model(model_name))
          call self.jump_model(option, model_name)
          return
        endif
      endif

      " Model -> Model or Behavior or Controller
      if self.is_model(self.name_to_path_model(word)) || self.in_build_path_model(word)
        call self.jump_model(option, word)
        return
      elseif self.is_behavior(self.name_to_path_behavior(word)) || self.in_build_path_behavior(word)
        call self.jump_behavior(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif

      " jump to Core Libraries
      if len(libs) == 0
        let libs = self.get_libs()
      endif
      let priority_order = ['', 'Behavior']
      for suffix in priority_order
        let target = word . suffix
        if has_key(libs, target)
          call self.jump_lib(option, target)
          return
        endif
      endfor

    endif
    "}}}
    " in View(layout) "{{{
    if self.is_view(path)
      " let name = matchstr(l_word, '\(["'']\)\zs[0-9A-Za-z/_.]\+\ze\(["'']\)' )
      " View / $this->element('xxx') -> element
      let element_name = matchstr(line, '\(\$this->element(\s*["'']\)\zs[0-9A-Za-z/_.-]\+\ze\(["'']\)' )
      if strlen(element_name) > 0
        call self.smart_jump_element(element_name, option)
        return
      endif
      " View / $this->Html->css('xxx') -> css
      let stylesheet_name = matchstr(line, '\(\$this->Html->css(\s*["'']\)\zs[0-9A-Za-z/_.-]\+\ze\(["'']\)' )
      if strlen(stylesheet_name) > 0
        call self.smart_jump_stylesheet(stylesheet_name, option)
        return
      endif
      " View / $html->css('xxx') -> css
      let stylesheet_name = matchstr(line, '\(\$html->css(\s*["'']\)\zs[0-9A-Za-z/_.-]\+\ze\(["'']\)' )
      if strlen(stylesheet_name) > 0
        call self.smart_jump_stylesheet(stylesheet_name, option)
        return
      endif
      " View / $this->Html->script('xxx') -> script
      let script_name = matchstr(line, '\(\$this->Html->script(\s*["'']\)\zs[0-9A-Za-z/_.-]\+\ze\(["'']\)' )
      if strlen(script_name) > 0
        call self.smart_jump_script(script_name, option)
        return
      endif
      " View / $html->script('xxx') -> script
      let script_name = matchstr(line, '\(\$html->script(\s*["'']\)\zs[0-9A-Za-z/_.-]\+\ze\(["'']\)' )
      if strlen(script_name) > 0
        call self.smart_jump_script(script_name, option)
        return
      endif

      " View -> Helper or Model or Controller
      if self.is_helper(self.name_to_path_helper(word)) || self.in_build_path_helper(word)
        call self.jump_helper(option, word)
        return
      elseif self.is_model(self.name_to_path_model(word)) || self.in_build_path_model(word)
        call self.jump_model(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif

      " jump to Core Libraries
      if len(libs) == 0
        let libs = self.get_libs()
      endif
      let priority_order = ['', 'Helper', 'Component', 'Behavior']
      for suffix in priority_order
        let target = word . suffix
        if has_key(libs, target)
          call self.jump_lib(option, target)
          return
        endif
      endfor

    endif
    " }}}
    " in Component "{{{
    if self.is_component(path)

      " Component -> Model or Behavior or Component or Controller
      if self.is_model(self.name_to_path_model(word)) || self.in_build_path_model(word)
        call self.jump_model(option, word)
        return
      elseif self.is_behavior(self.name_to_path_behavior(word)) || self.in_build_path_behavior(word)
        call self.jump_behavior(option, word)
        return
      elseif self.is_component(self.name_to_path_component(word)) || self.in_build_path_component(word)
        call self.jump_component(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif

      " jump to Core Libraries
      if len(libs) == 0
        let libs = self.get_libs()
      endif
      let priority_order = ['', 'Behavior', 'Component']
      for suffix in priority_order
        let target = word . suffix
        if has_key(libs, target)
          call self.jump_lib(option, target)
          return
        endif
      endfor

    endif
    "}}}
    " in Behavior "{{{
    if self.is_behavior(path)

      " Behavior -> Model or Behavior
      if self.is_model(self.name_to_path_model(word)) || self.in_build_path_model(word)
        call self.jump_model(option, word)
        return
      elseif self.is_behavior(self.name_to_path_behavior(word)) || self.in_build_path_behavior(word)
        call self.jump_behavior(option, word)
        return
      endif

      " jump to Core Libraries
      if len(libs) == 0
        let libs = self.get_libs()
      endif
      let priority_order = ['', 'Behavior']
      for suffix in priority_order
        let target = word . suffix
        if has_key(libs, target)
          call self.jump_lib(option, target)
          return
        endif
      endfor

    endif
    "}}}
    " in Helper {{{
    if self.is_helper(path)

      " Helper -> Helper Controller
      if self.is_helper(self.name_to_path_helper(word)) || self.in_build_path_helper(word)
        call self.jump_helper(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif

      " jump to Core Libraries
      if len(libs) == 0
        let libs = self.get_libs()
      endif
      let priority_order = ['', 'Helper']
      for suffix in priority_order
        let target = word . suffix
        if has_key(libs, target)
          call self.jump_lib(option, target)
          return
        endif
      endfor

    endif
    " }}}
    " in TestController "{{{
    if self.is_testcontroller(path)
      " TestController -> Fixture or Controller
      if self.is_fixture(self.name_to_path_fixture(word))
        call self.jump_fixture(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif
    endif
    " }}}
    " in TestModel "{{{
    if self.is_testmodel(path)
      " TestModel -> Fixture or Model
      if self.is_fixture(self.name_to_path_fixture(word))
        call self.jump_fixture(option, word)
        return
      elseif self.is_model(self.name_to_path_model(word)) || self.in_build_path_model(word)
        call self.jump_model(option, word)
        return
      endif
    endif
    " }}}
    " in TestBehavior "{{{
    if self.is_testbehavior(path)
      " TestBehavior -> Fixture or Behavior
      if self.is_fixture(self.name_to_path_fixture(word))
        call self.jump_fixture(option, word)
        return
      elseif self.is_behavior(self.name_to_path_behavior(word)) || self.in_build_path_behavior(word)
        call self.jump_behavior(option, word)
        return
      endif
    endif
    " }}}
    " in TestComponent "{{{
    if self.is_testcomponent(path)
      " TestComponent -> Fixture or Component
      if self.is_fixture(self.name_to_path_fixture(word))
        call self.jump_fixture(option, word)
        return
      elseif self.is_component(self.name_to_path_component(word)) || self.in_build_path_component(word)
        call self.jump_component(option, word)
        return
      endif
    endif
    " }}}
    " in TestHelper "{{{
    if self.is_testhelper(path)
      " TestHelper -> Fixture or Helper
      if self.is_fixture(self.name_to_path_fixture(word))
        call self.jump_fixture(option, word)
        return
      elseif self.is_helper(self.name_to_path_helper(word)) || self.in_build_path_helper(word)
        call self.jump_helper(option, word)
        return
      endif
    endif
    " }}}
    " in Fixture "{{{
    if self.is_fixture(path)

      " Fixture -> Model
      if self.is_model(self.name_to_path_model(word)) || self.in_build_path_model(word)
        call self.jump_model(option, word)
        return
      endif

    endif
    "}}}
    " in Shell "{{{
    if self.is_shell(path)

      " Shell -> Task, Model
      if self.is_task(self.name_to_path_task(word))
        call self.jump_task(option, word)
        return
      elseif self.is_model(self.name_to_path_model(word)) || self.in_build_path_model(word)
        call self.jump_model(option, word)
        return
      endif

      " jump to Core Libraries
      if len(libs) == 0
        let libs = self.get_libs()
      endif

      let priority_order = ['Task', '', 'Behavior', 'Component', 'Helper']
      for suffix in priority_order
        let target = word . suffix
        if has_key(libs, target)
          call self.jump_lib(option, target)
          return
        endif
      endfor

    endif
    "}}}
    " in Task "{{{
    if self.is_task(path)

      " Task -> Model
      if self.is_model(self.name_to_path_model(word)) || self.in_build_path_model(word)
        call self.jump_model(option, word)
        return
      endif

      " jump to Core Libraries
      if len(libs) == 0
        let libs = self.get_libs()
      endif
      let priority_order = ['', 'Behavior', 'Component', 'Helper']
      for suffix in priority_order
        let target = word . suffix
        if has_key(libs, target)
          call self.jump_lib(option, target)
          return
        endif
      endfor

    endif
    "}}}

    " Global {{{
    " Configure::load('xxx'); -> config
    let config_name = matchstr(line, '\(Configure::load(\s*["'']\)\zs[0-9A-Za-z/_.]\+\ze\(["'']\s*)\)')
    if strlen(config_name) > 0 && filereadable(self.paths.configs . config_name . '.php')
      call self.jump_config(option, config_name)
      return
    endif

    " jump to Core Libraries
    if strlen(word) > 0
      if has_key(self.get_libs(), word)
        call self.jump_lib(option, word)
        return
      endif
    endif
    " }}}



    " Combination Pattern (I lowered priority most. Because it might conflict with other patterns.)
    
    " array('controller' => 'Hoge', 'action' => 'fuga') ->  HogeController::fuga()
    " array('controller' => 'Hoge', 'action' => 'fuga', 'admin' => true) -> HogeController::admin_fuga()
    let controller_name = matchstr(line, '\(array(.*["'']controller["'']\s*=>\s*["'']\)\zs\w\+\ze\(["''].*)\)')
    let action_name = matchstr(line, '\(array(.*["'']action["'']\s*=>\s*["'']\)\zs\w\+\ze\(["''].*)\)')
    let controllers = self.get_controllers()

    if strlen(controller_name) > 0 && strlen(action_name) > 0

      let controller_name = cake#util#camelize(controller_name)
      if strlen(matchstr(line, 'array(.*["'']admin["'']\s*=>\s*true.*)')) > 0
        let action_name = 'admin_' . action_name
      endif

      if has_key(controllers, controller_name)
        call cake#util#open_file(controllers[controller_name], option, self.get_line_in_controller(controller_name, action_name))
        return
      endif

    endif

    " Default action
    call self.gf(option)

  endfunction "}}}
  function! self.smart_jump_script(script_name, option) "{{{
    let scripts = []

    if match(a:script_name, '/') > 0
      let script_dir = 'webroot/js/' . a:script_name[:strridx(a:script_name, '/')]
      let script_name = a:script_name[strridx(a:script_name, '/')+1:]
    else
      let script_dir = 'webroot/js/'
      let script_name = a:script_name
    endif


    " default
    for script_path in split(globpath(self.paths.app . script_dir, "**/" . script_name . ".js"), "\n")
      if filereadable(script_path)
        call add(scripts, script_path)
      endif
    endfor

    " in themes
    let themes = keys(self.get_themes())
    for theme_name in themes
      for script_path in split(globpath(self.paths.themes . theme_name . '/' . script_dir, "**/" . script_name . ".js"), "\n")
        if filereadable(script_path)
          call add(scripts, script_path)
        endif
      endfor
    endfor


    let i = len(scripts)
    if i == 0
      return
    elseif i == 1
      call cake#util#open_file(scripts[0], a:option, 0)
      return
    elseif i > 1
      let n = 1
      let tmp_choices = []
      for str in scripts
        let str = n . ": " . self.abbreviate(str)
        call add(tmp_choices, str)
        let n = n + 1
      endfor
      let choices = join(tmp_choices,"\n")
      let c = confirm('Which file do you jump to?', choices, 0)
      if c > 0
        let index = c - 1
        call cake#util#open_file(scripts[index], a:option, 0)
        return
      endif
    endif

    " Default action
    call self.gf(option)
  endfunction "}}}
  function! self.smart_jump_stylesheet(stylesheet_name, option) "{{{
    let stylesheets = []

    if match(a:stylesheet_name, '/') > 0
      let stylesheet_dir = 'webroot/css/' . a:stylesheet_name[:strridx(a:stylesheet_name, '/')]
      let stylesheet_name = a:stylesheet_name[strridx(a:stylesheet_name, '/')+1:]
    else
      let stylesheet_dir = 'webroot/css/'
      let stylesheet_name = a:stylesheet_name
    endif


    " default
    for stylesheet_path in split(globpath(self.paths.app . stylesheet_dir, "**/" . stylesheet_name . ".css"), "\n")
      if filereadable(stylesheet_path)
        call add(stylesheets, stylesheet_path)
      endif
    endfor

    " in themes
    let themes = keys(self.get_themes())
    for theme_name in themes
      for stylesheet_path in split(globpath(self.paths.themes . theme_name . '/' . stylesheet_dir, "**/" . stylesheet_name . ".css"), "\n")
        if filereadable(stylesheet_path)
          call add(stylesheets, stylesheet_path)
        endif
      endfor
    endfor

    let i = len(stylesheets)
    if i == 0
      return
    elseif i == 1
      call cake#util#open_file(stylesheets[0], a:option, 0)
      return
    elseif i > 1
      let n = 1
      let tmp_choices = []
      for str in stylesheets
        let str = n . ": " . self.abbreviate(str)
        call add(tmp_choices, str)
        let n = n + 1
      endfor
      let choices = join(tmp_choices,"\n")
      let c = confirm('Which file do you jump to?', choices, 0)
      if c > 0
        let index = c - 1
        call cake#util#open_file(stylesheets[index], a:option, 0)
        return
      endif
    endif

    " Default action
    call self.gf(option)
  endfunction "}}}
  function! self.smart_jump_element(element_name, option) "{{{
    let elements = []

    if match(a:element_name, '/') > 0
      let element_dir = self.vars.element_dir . a:element_name[:strridx(a:element_name, '/')]
      let element_name = a:element_name[strridx(a:element_name, '/')+1:]
    else
      let element_dir = self.vars.element_dir
      let element_name = a:element_name
    endif


    " default
    for element_path in split(globpath(self.paths.views . element_dir, "**/" . element_name . ".ctp"), "\n")
      if filereadable(element_path)
        call add(elements, element_path)
      endif
    endfor

    " in themes
    let themes = keys(self.get_themes())
    for theme_name in themes
      for element_path in split(globpath(self.paths.themes . theme_name . '/' . element_dir, "**/" . element_name . ".ctp"), "\n")
        if filereadable(element_path)
          call add(elements, element_path)
        endif
      endfor
    endfor


    let i = len(elements)
    if i == 0
      return
    elseif i == 1
      call cake#util#open_file(elements[0], a:option, 0)
      return
    elseif i > 1
      let n = 1
      let tmp_choices = []
      for str in elements
        let str = n . ": " . self.abbreviate(str)
        call add(tmp_choices, str)
        let n = n + 1
      endfor
      let choices = join(tmp_choices,"\n")
      let c = confirm('Which file do you jump to?', choices, 0)
      if c > 0
        let index = c - 1
        call cake#util#open_file(elements[index], a:option, 0)
        return
      endif
    endif

    " Default action
    call self.gf(option)
  endfunction "}}}
  function! self.smart_jump_layout(layout_name, option) "{{{
    let layouts = []

    if match(a:layout_name, '/') > 0
      let layout_dir = self.vars.layout_dir . a:layout_name[:strridx(a:layout_name, '/')]
      let layout_name = a:layout_name[strridx(a:layout_name, '/')+1:]
    else
      let layout_dir = self.vars.layout_dir
      let layout_name = a:layout_name
    endif

    " in default
    for layout_path in split(globpath(self.paths.views . layout_dir, "**/" . layout_name . ".ctp"), "\n")
      if filereadable(layout_path)
        call add(layouts, layout_path)
      endif
    endfor

    " in themes
    let themes = keys(self.get_themes())
    for theme_name in themes
      for layout_path in split(globpath(self.paths.themes . theme_name . '/' . layout_dir, "**/" . layout_name . ".ctp"), "\n")
        if filereadable(layout_path)
          call add(layouts, layout_path)
        endif
      endfor
    endfor

    let i = len(layouts)
    if i == 0
      return
    elseif i == 1
      call cake#util#open_file(layouts[0], a:option, 0)
      return
    elseif i > 1
      let n = 1
      let tmp_choices = []
      for str in layouts
        let str = n . ": " . self.abbreviate(str)
        call add(tmp_choices, str)
        let n = n + 1
      endfor
      let choices = join(tmp_choices,"\n")
      let c = confirm('Which file do you jump to?', choices, 0)
      if c > 0
        let index = c - 1
        call cake#util#open_file(layouts[index], a:option, 0)
        return
      endif
    endif

    " Default action
    call self.gf(option)
  endfunction "}}}
  function! self.gf(option) "{{{
    if a:option == 'n'
      exec "normal! gf"
    elseif a:option == 's'
      exec "normal! \<C-w>f"
    elseif a:option == 't'
      exec "normal! \<C-w>gf"
    endif
  endfunction "}}}
  " ============================================================

  " Functions: in_build_path_xxx()
  " ============================================================
  function! self.in_build_path_model(name) "{{{
    for build_path in self.get_build_paths('models')
      for path in split(globpath(build_path, "*.php"), "\n")
        if self.path_to_name_model(path) == a:name
          return 1
        endif
      endfor
    endfor
    return 0
  endfunction "}}}
  function! self.in_build_path_behavior(name) "{{{
    for build_path in self.get_build_paths('behaviors')
      for path in split(globpath(build_path, "*.php"), "\n")
        if self.path_to_name_behavior(path) == a:name
          return 1
        endif
      endfor
    endfor
    return 0
  endfunction "}}}
  function! self.in_build_path_component(name) "{{{
    for build_path in self.get_build_paths('components')
      for path in split(globpath(build_path, "*.php"), "\n")
        if self.path_to_name_component(path) == a:name
          return 1
        endif
      endfor
    endfor
    return 0
  endfunction "}}}
  function! self.in_build_path_helper(name) "{{{
    for build_path in self.get_build_paths('helpers')
      for path in split(globpath(build_path, "*.php"), "\n")
        if self.path_to_name_helper(path) == a:name
          return 1
        endif
      endfor
    endfor
    return 0
  endfunction "}}}
  " ============================================================

  " Functions: common functions
  " ============================================================
  function! self.get_line_in_controller(controller_name, action_name) "{{{
    let line = 0

    if a:action_name != ''
      let cmd = 'grep -n -E "^\s*function\s*' . a:action_name . '\s*\(" ' . self.name_to_path_controller(a:controller_name) . ' | cut -f 1'
      " Extract line number from grep result.
      let n = matchstr(system(cmd), '\(^\d\+\)')
      if strlen(n) > 0
        let line = str2nr(n)
      endif
    endif

    return line
  endfunction "}}}
  function! self.args_to_targets(args) "{{{
    let targets = []
    for arg in a:args
      if arg == 'n' || arg == 's' || arg == 'v' || arg == 't'
        continue
      endif
      call add(targets, arg)
    endfor
    return targets
  endfunction "}}}
  function! self.abbreviate(path) "{{{
    if self.is_view(a:path)
      return substitute(a:path, self.paths.views, "", "")
    endif
    return a:path
  endfunction "}}}
  function! self.show_cakephp_app() "{{{
    echo '[cake.vim] ' . self.paths.app
  endfunction "}}}
  function! self.set_log(log) "{{{
    " default settings of log.
    if !has_key(a:log, 'debug') || a:log['debug'] == ''
      let a:log['debug'] = self.paths.app . "tmp/logs/debug.log"
    endif

    if !has_key(a:log, 'error') || a:log['error'] == ''
      let a:log['error'] = self.paths.app . "tmp/logs/error.log"
    endif
  endfunction "}}}
  function! self.name_to_path_config(name) "{{{
    return self.paths.configs . a:name . ".php"
  endfunction "}}}
  function! self.tail_log(log_name) "{{{
    if !has_key(g:cakephp_log, a:log_name)
      call cake#util#echo_warning(a:log_name . " is not found. please set g:cakephp_log['" . a:log_name . "'] = '/path/to/log_name.log'.")
      return
    endif

    call cake#util#open_tail_log_window(g:cakephp_log[a:log_name], g:cakephp_log_window_size)
  endfunction "}}}
  function! self.in_theme(view_path) "{{{
    if match(a:view_path, self.paths.themes) != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.get_viewtheme(view_path) " {{{
    let theme = ''
    " View in now a theme?
    if self.in_theme(a:view_path)
      let theme = cake#util#get_topdir(a:view_path[strlen(self.paths.themes):])
    endif
    return theme
  endfunction "}}}
  function! self.clip_element(bang, ...) range "{{{
    let range = a:firstline . ',' . a:lastline
    let args = split(a:1, '[^0-9A-Za-z_/\-\\]\+')
    let element_name = get(args, 0)
    let view_path = expand("%:p")
    let theme = ''
    if len(args) > 1
      let theme = get(args, 1)
    else
      let theme = self.get_viewtheme(view_path)
    endif

    if theme == ''
      " default
      let output_file = self.paths.views . self.vars.element_dir . element_name . '.ctp'
    else
      " using theme
      let output_file = self.paths.themes . theme . '/' . self.vars.element_dir . element_name . '.ctp'
    endif


    if filereadable(output_file) && !a:bang
      call cake#util#echo_warning(output_file . ' already exists.(add ! to override)')
      return
    endif
    if !isdirectory(fnamemodify(output_file, ':h'))
      if a:bang
        call mkdir(fnamemodify(output_file, ':h'), 'p')
      else
        call cake#util#echo_warning(fnamemodify(output_file, ':h') . ' is not such directory.(add ! to make directory.)')
        return
      endif
    endif

    let tmp = @@
    silent exec range . 'yank'
    let element = @@
    let @@ = tmp

    let replace_text = "<?php echo $this->element('" . element_name . "'); ?>"
    silent exec "normal! :". range . "change!\<CR>" . replace_text . "\<CR>.\<CR>"
    call writefile(split(element, "\n", 1), output_file, 'b')

    echo 'Save Element: '. output_file

  endfunction "}}}
  function! self.get_build_paths(name) "{{{
    let paths = []
    let app_config = cake#util#eval_json_file(self.paths.app . g:cakephp_app_config_file)
    if has_key(app_config, 'build_path') && has_key(app_config.build_path, a:name)
      let paths = app_config.build_path[a:name]
    endif
    return paths
  endfunction "}}}
  " ============================================================

  return self
endfunction
" ============================================================



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
