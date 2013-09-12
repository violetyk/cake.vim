" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.

let s:save_cpo = &cpo
set cpo&vim

function! cake#cake13#factory(path_app)
  " like class extends.
  let self = cake#factory(a:path_app)
  " self.base is parent class.
  let self.base = deepcopy(self)

  let self.paths = {
        \ 'app'             : a:path_app,
        \ 'controllers'     : a:path_app . 'controllers/',
        \ 'components'      : a:path_app . 'controllers/components/',
        \ 'libs'            : a:path_app . 'libs/',
        \ 'models'          : a:path_app . 'models/',
        \ 'behaviors'       : a:path_app . 'models/behaviors/',
        \ 'views'           : a:path_app . 'views/',
        \ 'helpers'         : a:path_app . 'views/helpers/',
        \ 'themes'          : a:path_app . 'views/themed/',
        \ 'configs'         : a:path_app . 'config/',
        \ 'shells'          : a:path_app . 'vendors/shells/',
        \ 'tasks'           : a:path_app . 'vendors/shells/tasks/',
        \ 'test'            : a:path_app . 'tests/',
        \ 'testcases'       : a:path_app . 'tests/cases/',
        \ 'testcontrollers' : a:path_app . 'tests/cases/controllers/',
        \ 'testcomponents'  : a:path_app . 'tests/cases/components/',
        \ 'testmodels'      : a:path_app . 'tests/cases/models/',
        \ 'testbehaviors'   : a:path_app . 'tests/cases/behaviors/',
        \ 'testhelpers'     : a:path_app . 'tests/cases/helpers/',
        \ 'fixtures'        : a:path_app . 'tests/fixtures/',
        \}

  let self.vars =  {
        \ 'layout_dir'      : 'layouts/',
        \ 'element_dir'     : 'elements/',
        \}

  " cakephp core library's path
  if exists("g:cakephp_core_path") && isdirectory(g:cakephp_core_path)
    let path_core = g:cakephp_core_path
  else
    let app_config = cake#util#eval_json_file(self.paths.app . g:cakephp_app_config_file)
    if has_key(app_config, 'cake')
      let path_core = app_config.cake
    else
      let path_core = cake#util#dirname(self.paths.app) . '/cake/'
    endif
  endif

  let cores = {
        \ 'core'        : path_core,
        \ 'lib'         : path_core . 'libs/',
        \ 'controllers' : path_core . 'libs/controller/',
        \ 'components'  : path_core . 'libs/controller/components/',
        \ 'models'      : path_core . 'libs/model/',
        \ 'behaviors'   : path_core . 'libs/model/behaviors/',
        \ 'helpers'     : path_core . 'libs/view/helpers/',
        \ 'console'     : path_core . 'console/',
        \ 'shells'      : path_core . 'console/libs/',
        \ 'tasks'       : path_core . 'console/libs/tasks/',
        \}

  let self.paths.cores = cores


  " Functions: self.get_dictionary()
  " [object_name : path]
  " ============================================================
  function! self.get_cores() "{{{
    let cores = {}

    " dispatcher
    let cores['Dispatcher'] = self.paths.cores.core . 'dispatcher.php'

    " cores
    for path in split(globpath(self.paths.cores.lib, "*\.php"), "\n")
      let name = cake#util#camelize(fnamemodify(path, ":t:r"))
      let cores[name] = path
    endfor
    " cores/cache
    for path in split(globpath(self.paths.cores.lib . 'cache/', "*\.php"), "\n")
      let name = cake#util#camelize(fnamemodify(path, ":t:r")) . 'Engine'
      let cores[name] = path
    endfor
    " cores/controller
    for path in split(globpath(self.paths.cores.controllers, "*\.php"), "\n")
        let name = cake#util#camelize(fnamemodify(path, ":t:r"))
      let cores[name] = path
    endfor
    " cores/controller/components
    for path in split(globpath(self.paths.cores.components, "*\.php"), "\n")
      let name = cake#util#camelize(fnamemodify(path, ":t:r")) . 'Component'
      let cores[name] = path
    endfor
    " cores/log
    for path in split(globpath(self.paths.cores.lib . 'log/', "*\.php"), "\n")
      let name = cake#util#camelize(fnamemodify(path, ":t:r"))
      let cores[name] = path
    endfor
    " cores/model
    for path in split(globpath(self.paths.cores.models, "*\.php"), "\n")
      if fnamemodify(path, ":t:r") == 'db_acl'
        let name = 'AclNode'
      else
        let name = cake#util#camelize(fnamemodify(path, ":t:r"))
      endif

      let cores[name] = path
    endfor
    " cores/model/behaviors
    for path in split(globpath(self.paths.cores.behaviors, "*\.php"), "\n")
      let name = cake#util#camelize(fnamemodify(path, ":t:r")) . 'Behavior'
      let cores[name] = path
    endfor
    " cores/model/datasources/*
    for path in split(globpath(self.paths.cores.models . 'datasources/', "**/*\.php"), "\n")
      let name = cake#util#camelize(fnamemodify(path, ":t:r"))
      let cores[name] = path
    endfor
    " cores/model/view
    let cores['Helper']    = self.paths.cores.lib . 'view/helper.php'
    let cores['MediaView'] = self.paths.cores.lib . 'view/media.php'
    let cores['ThemeView'] = self.paths.cores.lib . 'view/theme.php'
    let cores['View']      = self.paths.cores.lib . 'view/view.php'
    " cores/model/view/helpers
    for path in split(globpath(self.paths.cores.helpers, "*\.php"), "\n")
      if fnamemodify(path, ":t:r") == 'app_helper'
        let name = cake#util#camelize(fnamemodify(path, ":t:r"))
      else
        let name = cake#util#camelize(fnamemodify(path, ":t:r")) . 'Helper'
      endif

      let cores[name] = path
    endfor
    " console/libs/
    for path in split(globpath(self.paths.cores.shells, "*\.php"), "\n")
      if fnamemodify(path, ":t:r") == 'shell'
        let name = cake#util#camelize(fnamemodify(path, ":t:r"))
      else
        let name = cake#util#camelize(fnamemodify(path, ":t:r")) . 'Shell'
      endif
      let cores[name] = path
    endfor
    " console/cores/tasks
    for path in split(globpath(self.paths.cores.tasks, "*\.php"), "\n")
      let name = cake#util#camelize(fnamemodify(path, ":t:r")) . 'Task'
      let cores[name] = path
    endfor

    return cores
  endfunction "}}}
  function! self.get_controllers(...) "{{{
    let controllers = {}
    let is_fullname = (exists('a:1') && (a:1 > 0))? 1 : 0

    for path in split(globpath(self.paths.app, "**/*_controller\.php"), "\n")
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

    for path in split(globpath(self.paths.app, "*_model.php"), "\n")
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
  function! self.get_helpers(...) "{{{
    let helpers = {}
    let is_fullname = (exists('a:1') && (a:1 > 0))? 1 : 0

    for path in split(globpath(self.paths.helpers, "*.php"), "\n")
      let name = self.path_to_name_helper(path, is_fullname)
      let helpers[name] = path
    endfor

    for path in split(globpath(self.paths.app, "*_helper.php"), "\n")
      let helpers[self.path_to_name_helper(path, is_fullname)] = path
    endfor

    for build_path in self.get_build_paths('helpers')
      for path in split(globpath(build_path, "*.php"), "\n")
        let name = self.path_to_name_helper(path, is_fullname)
        if !has_key(helpers, name)
          let helpsers[name] = path
        endif
      endfor
    endfor

    return helpers
  endfunction " }}}
  function! self.get_views(controller_name) "{{{

    " key = func_name, val = line_number
    let views = {}

    " Extracting the function name.
    let cmd = 'grep -nE "^\s*function\s*\w+\s*\(" ' . self.name_to_path_controller(a:controller_name)
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
    let suffix = (exists('a:2') && a:2 > 0)?  'Controller' : ''

    return cake#util#camelize(substitute(fnamemodify(path, ":t:r"), "_controller$", "", "")) . suffix
  endfunction "}}}
  function! self.path_to_name_model(...) "{{{
    let path = a:1
    return cake#util#camelize(substitute(fnamemodify(path, ":t:r"), "_model$", "", ""))
  endfunction "}}}
  function! self.path_to_name_fixture(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'Fixture' : ''

    return cake#util#camelize(substitute(fnamemodify(path, ":t:r"), "_fixture$", "", "")) . suffix
  endfunction "}}}
  function! self.path_to_name_component(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'Component' : ''
    return cake#util#camelize(fnamemodify(path, ":t:r")) . suffix
  endfunction "}}}
  function! self.path_to_name_shell(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'Shell' : ''
    return cake#util#camelize(fnamemodify(a:path, ":t:r")) . suffix
  endfunction "}}}
  function! self.path_to_name_task(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'Task' : ''
    return cake#util#camelize(fnamemodify(path, ":t:r")) . suffix
  endfunction "}}}
  function! self.path_to_name_behavior(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'Behavior' : ''
    return cake#util#camelize(fnamemodify(path, ":t:r")) . suffix
  endfunction "}}}
  function! self.path_to_name_helper(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'Helper' : ''
    return cake#util#camelize(substitute(fnamemodify(path, ":t:r"), "_helper$", "", "")) . suffix
  endfunction "}}}
  function! self.path_to_name_testcontroller(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'ControllerTestCase' : ''
    return cake#util#camelize(substitute(fnamemodify(path, ":t:r"), "_controller.test$", "", "")) . suffix
  endfunction "}}}
  function! self.path_to_name_testmodel(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'ControllerTestCase' : ''
    return cake#util#camelize(substitute(fnamemodify(path, ":t:r"), ".test$", "", "")) . suffix
  endfunction "}}}
  function! self.path_to_name_testcomponent(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'ComponentTestCase' : ''
    return cake#util#camelize(substitute(fnamemodify(path, ":t:r"), ".test$", "", "")) . suffix
  endfunction "}}}
  function! self.path_to_name_testbehavior(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'BahaviorTestCase' : ''
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), ".test$", "", "")) . suffix
  endfunction "}}}
  function! self.path_to_name_testhelper(...) "{{{
    if a:0 == 0
      return ''
    endif
    let path = a:1
    let suffix = (exists('a:2') && a:2 > 0)?  'HelperTestCase' : ''
    return cake#util#camelize(substitute(fnamemodify(path, ":t:r"), ".test$", "", "")) . suffix
  endfunction "}}}
  function! self.path_to_name_theme(path) "{{{
      return fnamemodify(a:path, ":p:h:t")
    endfunction "}}}
  " ============================================================

  " Functions: self.name_to_path_xxx()
  " ============================================================
  function! self.name_to_path_controller(name) "{{{
    let controller_name = cake#util#decamelize(a:name) . "_controller.php"
    if filereadable(self.paths.app . controller_name)
      return self.paths.app . controller_name
    else
      return self.paths.controllers . controller_name
    endif
  endfunction "}}}
  function! self.name_to_path_model(name) "{{{
    if filereadable(self.paths.app . cake#util#decamelize(a:name) . "_model.php")
      return self.paths.app . cake#util#decamelize(a:name) . "_model.php"
    else
      return self.paths.models . cake#util#decamelize(a:name) . ".php"
    endif
  endfunction "}}}
  function! self.name_to_path_component(name) "{{{
    return self.paths.components . cake#util#decamelize(a:name) . ".php"
  endfunction "}}}
  function! self.name_to_path_shell(name) "{{{
    return self.paths.shells . cake#util#decamelize(a:name) . ".php"
  endfunction "}}}
  function! self.name_to_path_task(name) "{{{
    return self.paths.tasks . cake#util#decamelize(a:name) . ".php"
  endfunction "}}}
  function! self.name_to_path_behavior(name) "{{{
    return self.paths.behaviors . cake#util#decamelize(a:name) . ".php"
  endfunction "}}}
  function! self.name_to_path_helper(name) "{{{
    if filereadable(self.paths.app . cake#util#decamelize(a:name) . "_helper.php")
      return self.paths.app . cake#util#decamelize(a:name) . "_helper.php"
    else
      return self.paths.helpers . cake#util#decamelize(a:name) . ".php"
    endif
  endfunction "}}}
  function! self.name_to_path_testmodel(name) "{{{
    return self.paths.testmodels . cake#util#decamelize(a:name) . ".test.php"
  endfunction "}}}
  function! self.name_to_path_testbehavior(name) "{{{
    return self.paths.testbehaviors . cake#util#decamelize(a:name) . ".test.php"
  endfunction "}}}
  function! self.name_to_path_testcomponent(name) "{{{
    return self.paths.testcomponents . cake#util#decamelize(a:name) . ".test.php"
  endfunction "}}}
  function! self.name_to_path_testcontroller(name) "{{{
    return self.paths.testcontrollers . cake#util#decamelize(a:name) . "_controller.test.php"
  endfunction "}}}
  function! self.name_to_path_testhelper(name) "{{{
    return self.paths.testhelpers . cake#util#decamelize(a:name) . ".test.php"
  endfunction "}}}
  function! self.name_to_path_fixture(name) "{{{
    return self.paths.fixtures. cake#util#decamelize(a:name) . "_fixture.php"
  endfunction "}}}
  function! self.name_to_path_view(controller_name, view_name, theme_name) "{{{
    if a:theme_name == ''
      return self.paths.views . cake#util#decamelize(a:controller_name) . "/" . a:view_name . ".ctp"
    else
      return self.paths.themes . a:theme_name . '/' . cake#util#decamelize(a:controller_name) . "/" . a:view_name . ".ctp"
    endif
  endfunction "}}}
  function! self.name_to_path_viewdir(controller_name, view_name, theme_name) "{{{
    if match(a:view_name, '/') > 0
      let dir = a:view_name[:strridx(a:view_name, '/')] . '/'
    else
      let dir = ''
    endif

    if a:theme_name == ''
      return self.paths.views . cake#util#decamelize(a:controller_name) . "/" . dir
    else
      return self.paths.themes . a:theme_name . '/' . cake#util#decamelize(a:controller_name) . "/" . dir
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
    elseif filereadable(a:path) && match(a:path, self.paths.app) != -1 && match(a:path, "_model\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_controller(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.controllers) != -1 && match(a:path, "_controller\.php$") != -1
      return 1
    elseif filereadable(a:path) && match(a:path, self.paths.app) != -1 && match(a:path, "_controller\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_fixture(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.fixtures) != -1 && match(a:path, "_fixture\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_component(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.components) != -1 && fnamemodify(a:path, ":e") == "php"
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_behavior(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.behaviors) != -1 && fnamemodify(a:path, ":e") == "php"
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_helper(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.helpers) != -1 && fnamemodify(a:path, ":e") == "php"
      return 1
    elseif filereadable(a:path) && match(a:path, self.paths.app) != -1 && match(a:path, "_helper\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_testcontroller(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.testcontrollers) != -1 && match(a:path, "_controller\.test\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_testmodel(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.testmodels) != -1 && match(a:path, "\.test\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_testbehavior(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.testbehaviors) != -1 && match(a:path, "\.test\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_testcomponent(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.testcomponents) != -1 && match(a:path, "\.test\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_testhelper(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.testhelpers) != -1 && match(a:path, "\.test\.php$") != -1
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_shell(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.shells) != -1 && fnamemodify(a:path, ":e") == "php"
      return 1
    endif
    return 0
  endfunction "}}}
  function! self.is_task(path) "{{{
    if filereadable(a:path) && match(a:path, self.paths.tasks) != -1 && fnamemodify(a:path, ":e") == "php"
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

  function! self.build_test_command(...) " {{{
    let path = a:1
    let cmd = ''

    let buffer = self.buffer(path)

    let test_path = ''
    if cake#util#in_array(buffer.type, ['model', 'fixture', 'controller', 'component', 'behavior', 'helper'])
      let Fnction = get(self, 'name_to_path_test' . buffer.type)
      let test_path = call(Fnction, [buffer.name], self)
      let Fnction = get(self, 'path_to_name_test' . buffer.type)
      let test_name = call(Fnction, [test_path], self)
    else
      let test_path = path
      let test_name = self.buffer(test_path).name
    endif

    if !filereadable(test_path)
      call cake#util#warning(printf("[cake.vim] Not found : %s", test_path))
      return cmd
    endif

    let shell = ''
    " app case
    if finddir(self.paths.testcases, escape(test_path, ' \') . ';') == self.paths.testcases
      let dir = cake#util#get_topdir(substitute(test_path, self.paths.testcases, '', ''))
      let shell = 'testsuite app case ' . dir . '/' . test_name
    endif

    if !strlen(shell)
      return cmd
    endif

    let cmd = printf('%scake %s -app %s', self.paths.cores.console, shell, self.paths.app)
    return cmd
  endfunction " }}}

  return self
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
