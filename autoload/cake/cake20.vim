" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.

let s:save_cpo = &cpo
set cpo&vim

function! cake#cake20#factory(path_app)
  " like class extends.
  let self = cake#factory(a:path_app)
  let self.base = deepcopy(self)

  let self.paths = {
        \ 'app'             : a:path_app,
        \ 'controllers'     : a:path_app . "Controller/",
        \ 'components'      : a:path_app . "Controller/Component/",
        \ 'models'          : a:path_app . "Model/",
        \ 'behaviors'       : a:path_app . "Model/Behavior/",
        \ 'views'           : a:path_app . "View/",
        \ 'helpers'         : a:path_app . "View/Helper/",
        \ 'themes'          : a:path_app . "View/Themed/",
        \ 'configs'         : a:path_app . "Config/",
        \ 'shells'          : a:path_app . "Console/Command/",
        \ 'tasks'           : a:path_app . "Console/Command/Task/",
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

  " Functions: self.get_dictionary()
  " [object_name : path]
  " ============================================================
  function! self.get_controllers() "{{{
    let controllers = {}

    for path in split(globpath(self.paths.controllers, "**/*Controller\.php"), "\n")
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

    return models

  endfunction
  " }}}
  function! self.get_views(controller_name) "{{{

    let views = []

    " Extracting the function name.
    let cmd = 'grep -E "^\s*public\s*function\s*\w+\s*\(" ' . self.name_to_path_controller(a:controller_name)
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
    return substitute(fnamemodify(a:path, ":t:r"), "Controller$", "", "")
  endfunction "}}}
  function! self.path_to_name_model(path) "{{{
    let name = fnamemodify(a:path, ":t:r")
    if name ==# 'AppModel'
      return 'App'
    else
      return name
    endif
  endfunction "}}}
  function! self.path_to_name_fixture(path) "{{{
    return cake#util#camelize(substitute(fnamemodify(a:path, ":t:r"), "Fixture$", "", ""))
  endfunction "}}}
  function! self.path_to_name_component(path) "{{{
    return substitute(fnamemodify(a:path, ":t:r"), "Component$", "", "")
  endfunction "}}}
  function! self.path_to_name_shell(path) "{{{
    return substitute(fnamemodify(a:path, ":t:r"), "Shell$", "", "")
  endfunction "}}}
  function! self.path_to_name_task(path) "{{{
    return substitute(fnamemodify(a:path, ":t:r"), "Task$", "", "")
  endfunction "}}}
  function! self.path_to_name_behavior(path) "{{{
    return substitute(fnamemodify(a:path, ":t:r"), "Behavior$", "", "")
  endfunction "}}}
  function! self.path_to_name_helper(path) "{{{
    return substitute(fnamemodify(a:path, ":t:r"), "Helper$", "", "")
  endfunction "}}}
  function! self.path_to_name_testcontroller(path) "{{{
    return substitute(fnamemodify(a:path, ":t:r"), "ControllerTest$", "", "")
  endfunction "}}}
  function! self.path_to_name_testmodel(path) "{{{
    let name = fnamemodify(a:path, ":t:r")
    if name ==# 'AppModel'
      return 'App'
    else
      return substitute(name, "Test$", "", "")
      return name
    endif
  endfunction "}}}
  function! self.path_to_name_testcomponent(path) "{{{
    return substitute(fnamemodify(a:path, ":t:r"), "ComponentTest$", "", "")
  endfunction "}}}
  function! self.path_to_name_testbehavior(path) "{{{
    return substitute(fnamemodify(a:path, ":t:r"), "BehaviorTest$", "", "")
  endfunction "}}}
  function! self.path_to_name_testhelper(path) "{{{
    return substitute(fnamemodify(a:path, ":t:r"), "HelperTest$", "", "")
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
  " ============================================================

  return self
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
