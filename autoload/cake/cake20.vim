" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.

let s:save_cpo = &cpo
set cpo&vim

function! cake#cake20#factory(path_app)
  " like class extends.
  let self = cake#factory(a:path_app)
  " self.base is parent class.
  let self.base = deepcopy(self)

  let self.paths = {
        \ 'app'             : a:path_app,
        \ 'controllers'     : a:path_app . "Controller/",
        \ 'components'      : a:path_app . "Controller/Component/",
        \ 'libs'            : a:path_app . 'Lib/',
        \ 'models'          : a:path_app . "Model/",
        \ 'behaviors'       : a:path_app . "Model/Behavior/",
        \ 'views'           : a:path_app . "View/",
        \ 'helpers'         : a:path_app . "View/Helper/",
        \ 'themes'          : a:path_app . "View/Themed/",
        \ 'configs'         : a:path_app . "Config/",
        \ 'shells'          : a:path_app . "Console/Command/",
        \ 'tasks'           : a:path_app . "Console/Command/Task/",
        \ 'test'            : a:path_app . "Test/",
        \ 'testcases'       : a:path_app . "Test/Case/",
        \ 'testcontrollers' : a:path_app . "Test/Case/Controller/",
        \ 'testcomponents'  : a:path_app . "Test/Case/Controller/Component/",
        \ 'testmodels'      : a:path_app . "Test/Case/Model/",
        \ 'testbehaviors'   : a:path_app . "Test/Case/Model/Behavior/",
        \ 'testhelpers'     : a:path_app . "Test/Case/View/Helper/",
        \ 'fixtures'        : a:path_app . "Test/Fixture/",
        \}

  let self.vars =  {
        \ 'layout_dir'      : 'Layouts/',
        \ 'element_dir'     : 'Elements/',
        \}

  " cakephp core library's path
  if exists("g:cakephp_core_path") && isdirectory(g:cakephp_core_path)
    let path_core = g:cakephp_core_path
  else
    let app_config = cake#util#eval_json_file(self.paths.app . g:cakephp_app_config_file)
    if has_key(app_config, 'cake')
      let path_core = app_config.cake
    else
      let path_core = cake#util#dirname(self.paths.app) . '/lib/'
    endif
  endif

  let cores = {
        \ 'core'        : path_core,
        \ 'lib'         : path_core . 'Cake/',
        \ 'controllers' : path_core . 'Cake/Controller/',
        \ 'components'  : path_core . 'Cake/Controller/Component/',
        \ 'models'      : path_core . 'Cake/Model/',
        \ 'behaviors'   : path_core . 'Cake/Model/Behavior/',
        \ 'helpers'     : path_core . 'Cake/View/Helper/',
        \ 'console'     : path_core . 'Cake/Console/',
        \ 'shells'      : path_core . 'Cake/Console/Command/',
        \ 'tasks'       : path_core . 'Cake/Console/Command/Task/',
        \}

  let self.paths.cores = cores


  " Functions: self.get_dictionary()
  " [object_name : path]
  " ============================================================
  function! self.get_cores() "{{{
    let cores = {}

    let directories = [
          \ 'Cache',
          \ 'Configure',
          \ 'Controller',
          \ 'Core',
          \ 'Error',
          \ 'Event',
          \ 'I18n',
          \ 'Log',
          \ 'Model',
          \ 'Network',
          \ 'Routing',
          \ 'Test',
          \ 'TestSuite',
          \ 'Utility',
          \ 'View',
          \ ]

    for dir in directories
      for path in split(globpath(self.paths.cores.lib . dir,  "**/*\.php"), "\n")
        let name = fnamemodify(path, ":t:r")
        let cores[name] = path
      endfor
    endfor

    " /Cake/Console
    for path in split(globpath(self.paths.cores.lib . 'Console/',  "**/*\.php"), "\n")
      let name = fnamemodify(path, ":t:r")
      if name ==# 'cake' || match(path, '/Console/Templates/') > 0
        continue
      endif
      let cores[name] = path
    endfor

    return cores
  endfunction "}}}

  function! self.get_controllers(...) "{{{
    let controllers = {}
    let is_fullname = (exists('a:1') && (a:1 > 0))? 1 : 0

    for path in split(globpath(self.paths.controllers, "**/*Controller\.php"), "\n")
      let name = self.path_to_name_controller(path, is_fullname)
      let controllers[name] = path
    endfor

    return controllers
  endfunction "}}}
  function! self.get_models() "{{{

    let models = {}

    for path in split(globpath(self.paths.models, "*.php"), "\n")
      let models[self.path_to_name_model(path)] = path
    endfor

    for build_path in self.get_build_paths('models')
      for path in split(globpath(build_path, "*.php"), "\n")
        let name = self.path_to_name_model(path)
        if !has_key(models, name)
          let models[name] = path
        endif
      endfor
    endfor

    return models

  endfunction
  " }}}
  function! self.get_views(controller_name) "{{{

    " key = func_name, val = line_number
    let views = {}

    " Extracting the function name.
    let cmd = 'grep -nE "^\s*public\s*function\s*\w+\s*\(" ' . self.name_to_path_controller(a:controller_name)
    for line in split(system(cmd), "\n")

      " cast int
      let line_number = matchstr(line, '^\d\+') + 0

      let s = matchend(line, "\s*function\s*.")
      let e = match(line, "(")
      let func_name = cake#util#strtrim(strpart(line, s, e-s))

      " Callback functions are not eligible.
      if func_name !~ "^_" && func_name !=? "beforeFilter" && func_name !=? "beforeRender" && func_name !=? "afterFilter"
        let views[func_name] = line_number
      endif
    endfor

    return views

  endfunction " }}}
  " ============================================================


  " Functions: self.path_to_name_xxx()
  " ============================================================
  function! self.path_to_name_controller(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return substitute(fnamemodify(path, ":t:r"), "Controller$", "", "")
    endif
  endfunction "}}}
  function! self.path_to_name_model(...) "{{{
    let path = a:1
    let name = fnamemodify(path, ":t:r")
    if name ==# 'AppModel'
      return 'App'
    else
      return name
    endif
  endfunction "}}}
  function! self.path_to_name_fixture(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return cake#util#camelize(substitute(fnamemodify(path, ":t:r"), "Fixture$", "", ""))
    endif
  endfunction "}}}
  function! self.path_to_name_component(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return substitute(fnamemodify(path, ":t:r"), "Component$", "", "")
    endif
  endfunction "}}}
  function! self.path_to_name_shell(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return substitute(fnamemodify(path, ":t:r"), "Shell$", "", "")
    endif
  endfunction "}}}
  function! self.path_to_name_task(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return substitute(fnamemodify(path, ":t:r"), "Task$", "", "")
    endif
  endfunction "}}}
  function! self.path_to_name_behavior(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return substitute(fnamemodify(path, ":t:r"), "Behavior$", "", "")
    endif
  endfunction "}}}
  function! self.path_to_name_helper(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return substitute(fnamemodify(path, ":t:r"), "Helper$", "", "")
    endif
  endfunction "}}}
  function! self.path_to_name_testcontroller(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return substitute(fnamemodify(path, ":t:r"), "ControllerTest$", "", "")
    endif
  endfunction "}}}
  function! self.path_to_name_testmodel(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1

    let name = fnamemodify(a:path, ":t:r")
    if (exists('a:2') && a:2 > 0)
      return name
    else
      if name ==# 'AppModel'
        return 'App'
      else
        return substitute(name, "Test$", "", "")
      endif
    endif
  endfunction "}}}
  function! self.path_to_name_testcomponent(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return substitute(fnamemodify(path, ":t:r"), "ComponentTest$", "", "")
    endif
  endfunction "}}}
  function! self.path_to_name_testbehavior(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return substitute(fnamemodify(path, ":t:r"), "BehaviorTest$", "", "")
    endif
  endfunction "}}}
  function! self.path_to_name_testhelper(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    if (exists('a:2') && a:2 > 0)
      return fnamemodify(path, ":t:r")
    else
      return substitute(fnamemodify(path, ":t:r"), "HelperTest$", "", "")
    endif
  endfunction "}}}
  function! self.path_to_name_theme(path) "{{{
      return fnamemodify(a:path, ":p:h:t")
  endfunction "}}}
  " ============================================================

  " Functions: self.name_to_path_xxx()
  " ============================================================
  function! self.name_to_path_controller(name) "{{{
    return self.paths.controllers . a:name . "Controller.php"
  endfunction "}}}
  function! self.name_to_path_model(name) "{{{
    return self.paths.models . a:name . ".php"
  endfunction "}}}
  function! self.name_to_path_component(name) "{{{
    return self.paths.components. a:name . "Component.php"
  endfunction "}}}
  function! self.name_to_path_shell(name) "{{{
    return self.paths.shells . a:name . "Shell.php"
  endfunction "}}}
  function! self.name_to_path_task(name) "{{{
    return self.paths.tasks . a:name . "Task.php"
  endfunction "}}}
  function! self.name_to_path_behavior(name) "{{{
    return self.paths.behaviors . a:name . "Behavior.php"
  endfunction "}}}
  function! self.name_to_path_helper(name) "{{{
    return self.paths.helpers . a:name . "Helper.php"
  endfunction "}}}
  function! self.name_to_path_testmodel(name) "{{{
    return self.paths.testmodels . a:name . "Test.php"
  endfunction "}}}
  function! self.name_to_path_testbehavior(name) "{{{
    return self.paths.testbehaviors . a:name . "BehaviorTest.php"
  endfunction "}}}
  function! self.name_to_path_testcomponent(name) "{{{
    return self.paths.testcomponents . a:name . "ComponentTest.php"
  endfunction "}}}
  function! self.name_to_path_testcontroller(name) "{{{
    return self.paths.testcontrollers . a:name . "ControllerTest.php"
  endfunction "}}}
  function! self.name_to_path_testhelper(name) "{{{
    return self.paths.testhelpers . a:name . "HelperTest.php"
  endfunction "}}}
  function! self.name_to_path_fixture(name) "{{{
    return self.paths.fixtures. a:name . "Fixture.php"
  endfunction "}}}
  function! self.name_to_path_view(controller_name, view_name, theme_name) "{{{
    if a:theme_name == ''
      return self.paths.views . a:controller_name . "/" . a:view_name . ".ctp"
    else
      return self.paths.themes . a:theme_name . '/' . a:controller_name . "/" . a:view_name . ".ctp"
    endif
  endfunction "}}}
  function! self.name_to_path_viewdir(controller_name, view_name, theme_name) "{{{
    if match(a:view_name, '/') > 0
      let dir = a:view_name[:strridx(a:view_name, '/')] . '/'
    else
      let dir = ''
    endif

    if a:theme_name == ''
      return self.paths.views . a:controller_name . "/" . dir
    else
      return self.paths.themes . a:theme_name . '/' . a:controller_name . "/" . dir
    endif
  endfunction "}}}
  " ============================================================

  " Functions: self.is_xxx()
  " ============================================================
  function! self.is_view(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.views) != -1 && fnamemodify(a:path, ":e") == "ctp"
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_model(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.models) != -1 && fnamemodify(a:path, ":e") == "php"
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_controller(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.controllers) != -1 && match(a:path, "Controller\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_fixture(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.fixtures) != -1 && match(a:path, "Fixture\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_component(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.components) != -1 && match(a:path, "Component\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_behavior(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.behaviors) != -1 && match(a:path, "Behavior\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_helper(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.helpers) != -1 && match(a:path, "Helper\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_testcontroller(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.testcontrollers) != -1 && match(a:path, "ControllerTest\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_testmodel(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.testmodels) != -1 && match(a:path, "ModelTest\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_testbehavior(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.testbehaviors) != -1 && match(a:path, "BehaviorTest\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_testcomponent(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.testcomponents) != -1 && match(a:path, "ComponentTest\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_testhelper(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.testhelpers) != -1 && match(a:path, "HelperTest\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_shell(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.shells) != -1 && match(a:path, "Shell\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_task(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.tasks) != -1 && match(a:path, "Task\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_lib(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.libs) != -1 && fnamemodify(a:path, ":e") == "php"
      return 1
    endif
    return 0
  endfunction "}}}
  " ============================================================

  function! self.build_test_command(...) "{{{
    let path = a:1
    let filter = ''
    if a:0 >= 2
      let filter = a:2
    endif

    let cmd = {}
    let buffer = self.buffer(path)

    let test_path = ''
    let test_name = ''
    if buffer.type == 'fixture'
      let test_path = self.name_to_path_testmodel(buffer.name)
      let test_name = buffer.name
    elseif cake#util#in_array(buffer.type, ['model', 'controller', 'component', 'behavior', 'helper'])
      let Fnction = get(self, 'name_to_path_test' . buffer.type)
      let test_path = call(Fnction, [buffer.name], self)
      let test_name = buffer.full_name
    elseif cake#util#in_array(buffer.type, ['testmodel', 'testcontroller', 'testcomponent', 'testbehavior', 'testhelper'])
      let test_path = path
      let Fnction = get(self, 'name_to_path_' . buffer.type[strlen('test'):])
      let alt_path = call(Fnction, [buffer.name], self)
      let Fnction = get(self, 'path_to_name_' . buffer.type[strlen('test'):])
      let test_name = call(Fnction, [alt_path, 1], self)
    endif

    if !filereadable(test_path)
      call cake#util#warning(printf("[cake.vim] Not found : %s", test_path))
      return cmd
    endif

    let shell = ''
    " app case
    if finddir(self.paths.testcases, escape(test_path, ' \') . ';') == self.paths.testcases

      let dir = cake#util#get_topdir(substitute(test_path, self.paths.testcases, '', ''))

      let cakephp_version = cake#version()
      if stridx(cakephp_version, '.') > 0
        let cakephp_version = matchstr(cakephp_version, '\d\+\.\d\+')
      endif
      let v = str2float(cakephp_version)
      if v < 2.1
        let shell = 'testsuite app ' . dir . '/' . test_name
      elseif v >= 2.1
        let shell = 'test app ' . dir . '/' . test_name
      endif

    endif

    if !strlen(shell)
      return cmd
    endif

    if strlen(filter) > 0
      let cmd.external = printf('%scake %s -app %s --filter %s', self.paths.cores.console, shell, self.paths.app, filter)
    else
      let cmd.external = printf('%scake %s -app %s', self.paths.cores.console, shell, self.paths.app)
    endif

    let cmd.async = cmd.external . ' --no-colors'

    return cmd
  endfunction "}}}

  return self
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
