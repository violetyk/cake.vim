" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.

let s:save_cpo = &cpo
set cpo&vim

function! cake#cake13#factory(path_app)
  " like class extends.
  let self = cake#factory(a:path_app)
  let self.base = deepcopy(self)

  let self.paths = {
        \ 'app'             : a:path_app,
        \ 'controllers'     : a:path_app . 'controllers/',
        \ 'components'      : a:path_app . 'controllers/components/',
        \ 'models'          : a:path_app . 'models/',
        \ 'behaviors'       : a:path_app . 'models/behaviors/',
        \ 'views'           : a:path_app . 'views/',
        \ 'helpers'         : a:path_app . 'views/helpers/',
        \ 'themes'          : a:path_app . 'views/themed/',
        \ 'configs'         : a:path_app . 'config/',
        \ 'shells'          : a:path_app . 'vendors/shells/',
        \ 'tasks'           : a:path_app . 'vendors/shells/tasks/',
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


  " Functions: self.get_dictionary()
  " [object_name : path]
  " ============================================================
  function! self.get_controllers() "{{{
    let controllers = {}

    for path in split(globpath(self.paths.app, "**/*_controller\.php"), "\n")
      let name = self.path_to_name_controller(path)
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

    return models

  endfunction
  " }}}
  function! self.get_helpers() "{{{
    let helpers = {}

    for path in split(globpath(self.paths.helpers, "*.php"), "\n")
      let name = self.path_to_name_helper(path)
      let helpers[name] = path
    endfor

    for path in split(globpath(self.paths.app, "*_helper.php"), "\n")
      let helpers[self.path_to_name_helper(path)] = path
    endfor

    return helpers
  endfunction " }}}
  function! self.get_views(controller_name) "{{{

    let views = []

    " Extracting the function name.
    let cmd = 'grep -E "^\s*function\s*\w+\s*\(" ' . self.name_to_path_controller(a:controller_name)
    for line in split(system(cmd), "\n")

      let s = matchend(line, "\s*function\s*.")
      let e = match(line, "(")
      let func_name = cake#util#strtrim(strpart(line, s, e-s))

      " Callback functions are not eligible.
      if func_name !~ "^_" && func_name !=? "beforeFilter" && func_name !=? "beforeRender" && func_name !=? "afterFilter"
        let views = add(views , func_name)
      endif
    endfor

    return views

  endfunction " }}}
  " ============================================================


  " Functions: self.path_to_name_xxx()
  " ============================================================
  function! self.path_to_name_controller(path) "{{{
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), "_controller$", "", ""))
  endfunction "}}}
  function! self.path_to_name_model(path) "{{{
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), "_model$", "", ""))
  endfunction "}}}
  function! self.path_to_name_fixture(path) "{{{
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), "_fixture$", "", ""))
  endfunction "}}}
  function! self.path_to_name_component(path) "{{{
    return cake#util#camelize(fnamemodify(a:path, ":t:r"))
  endfunction "}}}
  function! self.path_to_name_shell(path) "{{{
    return cake#util#camelize(fnamemodify(a:path, ":t:r"))
  endfunction "}}}
  function! self.path_to_name_task(path) "{{{
    return cake#util#camelize(fnamemodify(a:path, ":t:r"))
  endfunction "}}}
  function! self.path_to_name_behavior(path) "{{{
    return cake#util#camelize(fnamemodify(a:path, ":t:r"))
  endfunction "}}}
  function! self.path_to_name_helper(path) "{{{
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), "_helper$", "", ""))
  endfunction "}}}
  function! self.path_to_name_testcontroller(path) "{{{
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), "_controller.test$", "", ""))
  endfunction "}}}
  function! self.path_to_name_testmodel(path) "{{{
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), ".test$", "", ""))
  endfunction "}}}
  function! self.path_to_name_testcomponent(path) "{{{
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), ".test$", "", ""))
  endfunction "}}}
  function! self.path_to_name_testbehavior(path) "{{{
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), ".test$", "", ""))
  endfunction "}}}
  function! self.path_to_name_testhelper(path) "{{{
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), ".test$", "", ""))
  endfunction "}}}
  function! self.path_to_name_theme(path) "{{{
      return fnamemodify(a:path, ":p:h:t")
    endfunction "}}}
  " ============================================================

  " Functions: self.name_to_path_xxx()
  " ============================================================
  function! self.name_to_path_controller(name) "{{{
    return self.paths.controllers . cake#util#decamelize(a:name) . "_controller.php"
  endfunction "}}}
  function! self.name_to_path_model(name) "{{{
    return self.paths.models . cake#util#decamelize(a:name) . ".php"
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
    return self.paths.helpers . cake#util#decamelize(a:name) . ".php"
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
  " ============================================================

  return self
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
