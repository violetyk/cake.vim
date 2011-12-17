" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.

let s:save_cpo = &cpo
set cpo&vim

function! cake#factory(path_app)

  let self = {}
  let self.paths = {}
  let self.vars = {}

  " Functions: abstract methods.(These implement it in a subclass.) {{{
  " ============================================================
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

    return behaviors
  endfunction " }}}
  function! self.get_components() "{{{
    let components = {}

    for path in split(globpath(self.paths.components, "*.php"), "\n")
      let name = self.path_to_name_component(path)
      let components[name] = path
    endfor

    return components
  endfunction "}}}
  function! self.get_helpers() "{{{
    let helpers = {}

    for path in split(globpath(self.paths.helpers, "*.php"), "\n")
      let name = self.path_to_name_helper(path)
      let helpers[name] = path
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
    let func_name = ''
    let controllers = self.get_controllers()

    if a:0 >= 2
      " Controller name is specified in the argument.
      " let target = a:2
      let targets = self.args_to_targets(a:000)
    else
      " Controller name is inferred from the currently opened file (view or model or testcontroller).
      let path = expand("%:p")

      if self.is_view(path)
        " let target = expand("%:p:h:t")
        call add(targets, expand("%:p:h:t"))
        let func_name = expand("%:p:t:r")
      elseif self.is_model(path)
        " let target = cake#util#pluralize(self.path_to_name_model(path))
        call add(targets, cake#util#pluralize(self.path_to_name_model(path)))
      elseif self.is_testcontroller(path)
        " let target = self.path_to_name_testcontroller(path)
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
      let line = 0
      if func_name != ''
        let cmd = 'grep -n -E "^\s*function\s*' . func_name . '\s*\(" ' . self.name_to_path_controller(target) . ' | cut -f 1'
        " Extract line number from grep result.
        let n = matchstr(system(cmd), '\(^\d\+\)')
        if strlen(n) > 0
          let line = str2nr(n)
        endif
      endif

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
      elseif self.is_testmodel(path)
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

    if !self.is_controller(expand("%:p"))
      call cake#util#echo_warning("No Controller in current buffer.")
      return
    endif

    let split_option = a:1
    let view_name = a:2

    if a:0 >= 3
      let theme = a:3
    else
      let theme = (exists("g:cakephp_use_theme") && g:cakephp_use_theme != '')? g:cakephp_use_theme : ''
    endif

    let controller_name = self.path_to_name_controller(expand("%:p"))
    let view_path = self.name_to_path_view(controller_name, view_name, theme)

    " If the file does not exist, ask whether to create a new file.
    if !filewritable(view_path)
      if !cake#util#confirm_create_file(view_path)
        call cake#util#echo_warning(view_path . " is not found.")
        return
      endif
    endif

    let line = 0
    call cake#util#open_file(view_path, split_option, line)

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
  function! self.smart_jump(...) "{{{
    let option = a:1
    let path = expand("%:p")
    let line = getline('.')
    let word = expand('<cword>')
    let l_word = expand('<cWORD>')

    " in Controller "{{{
    if self.is_controller(path)
      let controller_name = self.path_to_name_controller(path)

      " Controller / function xxx() -> View
      let view_name = matchstr(line, '\(function\s\+\)\zs\w\+\ze\(\s*(\)')
      if strlen(view_name) > 0
        call self.smart_jump_view(controller_name, view_name, option)
        return
      endif
      " Controller / $this->render('xxx') -> View
      let view_name = matchstr(line, '\(\$this->render(\s*["'']\)\zs\w\+\ze\(["'']\s*)\)')
      if strlen(view_name) > 0
        call self.smart_jump_view(controller_name, view_name, option)
        return
      endif

      " Controller / var $layout = 'xxx'; -> layout
      let layout_name = matchstr(line, '\(var\s\+\$layout\s*=\s*["'']\)\zs\w\+\ze\(["''];\)' )
      if strlen(layout_name) > 0
        call self.smart_jump_layout(layout_name, option)
        return
      endif
      " Controller / $this->layout = 'xxx'; -> layout
      let layout_name = matchstr(line, '\(\$this->layout\s*=\s*["'']\)\zs\w\+\ze\(["''];\)' )
      if strlen(layout_name) > 0
        call self.smart_jump_layout(layout_name, option)
        return
      endif


      " Controller -> Model or Behavior or Component or Helper
      if self.is_model(self.name_to_path_model(word))
        call self.jump_model(option, word)
        return
      elseif self.is_behavior(self.name_to_path_behavior(word))
        call self.jump_behavior(option, word)
        return
      elseif self.is_component(self.name_to_path_component(word))
        call self.jump_component(option, word)
        return
      elseif self.is_helper(self.name_to_path_helper(word))
        call self.jump_helper(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif

    endif
    "}}}
    " in Model "{{{
    if self.is_model(path)

      " Model -> Model or Behavior or Controller
      if self.is_model(self.name_to_path_model(word))
        call self.jump_model(option, word)
        return
      elseif self.is_behavior(self.name_to_path_behavior(word))
        call self.jump_behavior(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif

    endif
    "}}}
    " in View(layout) "{{{
    if self.is_view(path)
      " let name = matchstr(l_word, '\(["'']\)\zs[0-9A-Za-z/_.]\+\ze\(["'']\)' )
      " View / $this->element('xxx') -> element
      let element_name = matchstr(line, '\(\$this->element(\s*["'']\)\zs[0-9A-Za-z/_.]\+\ze\(["'']\)' )
      if strlen(element_name) > 0
        call self.smart_jump_element(element_name, option)
        return
      endif
      " View / $this->Html->css('xxx') -> css
      let stylesheet_name = matchstr(line, '\(\$this->Html->css(\s*["'']\)\zs[0-9A-Za-z/_.]\+\ze\(["'']\)' )
      if strlen(stylesheet_name) > 0
        call self.smart_jump_stylesheet(stylesheet_name, option)
        return
      endif
      " View / $html->css('xxx') -> css
      let stylesheet_name = matchstr(line, '\(\$html->css(\s*["'']\)\zs[0-9A-Za-z/_.]\+\ze\(["'']\)' )
      if strlen(stylesheet_name) > 0
        call self.smart_jump_stylesheet(stylesheet_name, option)
        return
      endif
      " View / $this->Html->script('xxx') -> script
      let script_name = matchstr(line, '\(\$this->Html->script(\s*["'']\)\zs[0-9A-Za-z/_.]\+\ze\(["'']\)' )
      if strlen(script_name) > 0
        call self.smart_jump_script(script_name, option)
        return
      endif
      " View / $html->script('xxx') -> script
      let script_name = matchstr(line, '\(\$html->script(\s*["'']\)\zs[0-9A-Za-z/_.]\+\ze\(["'']\)' )
      if strlen(script_name) > 0
        call self.smart_jump_script(script_name, option)
        return
      endif

      " View -> Helper or Model or Controller
      if self.is_helper(self.name_to_path_helper(word))
        call self.jump_helper(option, word)
        return
      elseif self.is_model(self.name_to_path_model(word))
        call self.jump_model(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif

    endif
    " }}}
    " in Component "{{{
    if self.is_component(path)

      " Component -> Model or Behavior or Component or Controller
      if self.is_model(self.name_to_path_model(word))
        call self.jump_model(option, word)
        return
      elseif self.is_behavior(self.name_to_path_behavior(word))
        call self.jump_behavior(option, word)
        return
      elseif self.is_component(self.name_to_path_component(word))
        call self.jump_component(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif

    endif
    "}}}
    " in Behavior "{{{
    if self.is_behavior(path)

      " Behavior -> Model or Behavior
      if self.is_model(self.name_to_path_model(word))
        call self.jump_model(option, word)
        return
      elseif self.is_behavior(self.name_to_path_behavior(word))
        call self.jump_behavior(option, word)
        return
      endif

    endif
    "}}}
    " in Helper {{{
    if self.is_helper(path)

      " Helper -> Helper or Model or Behavior or Controller
      if self.is_helper(self.name_to_path_helper(word))
        call self.jump_helper(option, word)
        return
      elseif self.is_controller(self.name_to_path_controller(cake#util#pluralize(word)))
        call self.jump_controller(option, cake#util#pluralize(word))
        return
      endif

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
      elseif self.is_model(self.name_to_path_model(word))
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
      elseif self.is_behavior(self.name_to_path_behavior(word))
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
      elseif self.is_component(self.name_to_path_component(word))
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
      elseif self.is_helper(self.name_to_path_helper(word))
        call self.jump_helper(option, word)
        return
      endif
    endif
    " }}}
    " in Fixture "{{{
    if self.is_fixture(path)

      " Fixture -> Model
      if self.is_model(self.name_to_path_model(word))
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
      elseif self.is_model(self.name_to_path_model(word))
        call self.jump_model(option, word)
        return
      endif

    endif
    "}}}
    " in Task "{{{
    if self.is_task(path)

      " Task -> Model
      if self.is_model(self.name_to_path_model(word))
        call self.jump_model(option, word)
        return
      endif

    endif
    "}}}


    " Global {{{
    " Configure::load('xxx'); -> config
    let config_name = matchstr(line, '\(Configure::load(\s*["'']\)\zs[0-9A-Za-z/_.]\+\ze\(["'']\s*)\)')
    if strlen(config_name) > 0 && filereadable(self.paths.configs . config_name . '.php')
      call self.jump_config(option, config_name)
      return
    endif
    " }}}


  endfunction "}}}
  function! self.smart_jump_script(script_name, option) "{{{
    let scripts = []

    " default
    let script_path = self.paths.app . 'webroot/js/' . a:script_name . '.js'
    if filereadable(script_path)
      call add(scripts , script_path)
    endif

    let themes = keys(self.get_themes())
    for theme_name in themes
      let script_path = self.paths.themes . theme_name . '/webroot/js/' . a:script_name . '.js'
      if filereadable(script_path)
        call add(scripts, script_path)
      endif
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
  endfunction "}}}
  function! self.smart_jump_stylesheet(stylesheet_name, option) "{{{
    let stylesheets = []

    " default
    let stylesheet_path = self.paths.app . 'webroot/css/' . a:stylesheet_name . '.css'
    if filereadable(stylesheet_path)
      call add(stylesheets , stylesheet_path)
    endif

    let themes = keys(self.get_themes())
    for theme_name in themes
      let stylesheet_path = self.paths.themes . theme_name . '/webroot/css/' . a:stylesheet_name . '.css'
      if filereadable(stylesheet_path)
        call add(stylesheets, stylesheet_path)
      endif
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
  endfunction "}}}
  function! self.smart_jump_element(element_name, option) "{{{
    let elements = []

    " default
    let element_path = self.paths.views . self.vars.element_dir . a:element_name . '.ctp'
    if filereadable(element_path)
      call add(elements , element_path)
    endif

    let themes = keys(self.get_themes())
    for theme_name in themes
      let element_path = self.paths.themes . theme_name . '/' . self.vars.element_dir . a:element_name . '.ctp'
      if filereadable(element_path)
        call add(elements, element_path)
      endif
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
  endfunction "}}}
  function! self.smart_jump_layout(layout_name, option) "{{{
    let layouts = []

    " default
    let layout_path = self.paths.views . self.vars.layout_dir . a:layout_name . '.ctp'
    if filereadable(layout_path)
      call add(layouts, layout_path)
    endif

    let themes = keys(self.get_themes())
    for theme_name in themes
      let layout_path = self.paths.themes . theme_name . '/' . self.vars.layout_dir . a:layout_name . '.ctp'
      if filereadable(layout_path)
        call add(layouts, layout_path)
      endif
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
  endfunction "}}}
  function! self.smart_jump_view(controller_name, view_name, option) "{{{
    let views = []
    let themes = keys(self.get_themes())
    let themes = insert(themes, '') "no theme
    for theme_name in themes
      let view_path = self.name_to_path_view(a:controller_name, a:view_name, theme_name)
      if filereadable(view_path)
        call add(views, view_path)
      endif
    endfor

    let i = len(views)
    if i == 0
      return
    elseif i == 1
      call cake#util#open_file(views[0], a:option, 0)
      return
    elseif i > 1
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
        call cake#util#open_file(views[index], a:option, 0)
        return
      endif
    endif
  endfunction "}}}
  " ============================================================

  " Functions: common functions
  " ============================================================
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
  " ============================================================


  return self
endfunction
" ============================================================


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
