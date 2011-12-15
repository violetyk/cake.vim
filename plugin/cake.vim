" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.
" Last Change: 2011/12/15
" Version:     2.1.0

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
        \ 'query' : '/var/log/mysql/query.log',
        \ 'access': '/usr/local/apache2/logs/access_log'
        \ }
endif


" SECTION: Default Settings
" ============================================================
let g:cakephp_log_window_size = 15
" }}}
" SECTION: Script Variables {{{
" ============================================================
let s:cake = {}
let s:is_initialized = 0
" }}}

" Function: s:initialize() {{{
" ============================================================
function! s:initialize(path)

  let a:path_app = ''

  " set app directory of the project.
  if a:path != ''
    let a:path_app = fnamemodify(a:path, ":p")
  elseif exists("g:cakephp_app") && g:cakephp_app != ''
    let a:path_app = g:cakephp_app
  endif

  " call factory method
  if isdirectory(a:path_app . 'Controller') && isdirectory(a:path_app . 'Model') && isdirectory(a:path_app . 'View')
    let s:cake = cake#cake20#factory(a:path_app)
    let s:is_initialized = 1
    call s:map_commands()
  elseif isdirectory(a:path_app . 'controllers') && isdirectory(a:path_app . 'models') && isdirectory(a:path_app . 'views')
    let s:cake = cake#cake13#factory(a:path_app)
    let s:is_initialized = 1
    call s:map_commands()
  else
    call util#echo_warning("[cake.vim] Please set g:cakephp_app or :Cakephp {app}.")
    let s:is_initialized = 0
    return
  endif

  call s:cake.set_log(g:cakephp_log)
endfunction
" }}}
function! s:map_commands() "{{{
  if s:is_initialized == 0
    return
  endif

  nnoremap <buffer> <silent> <Plug>CakeJump       :<C-u>call <SID>smart_jump('n')<CR>
  nnoremap <buffer> <silent> <Plug>CakeSplitJump  :<C-u>call <SID>smart_jump('s')<CR>
  nnoremap <buffer> <silent> <Plug>CakeTabJump    :<C-u>call <SID>smart_jump('t')<CR>
  if !hasmapto('<Plug>CakeJump')
    nmap <buffer> gf <Plug>CakeJump
  endif
  if !hasmapto('<Plug>CakeSplitJump')
    nmap <buffer> <C-w>f <Plug>CakeSplitJump
  endif
  if !hasmapto('<Plug>CakeTabJump')
    nmap <buffer> <C-w>gf <Plug>CakeTabJump
  endif

endfunction "}}}
function! s:smart_jump(option) "{{{
  call s:cake.smart_jump(a:option)
endfunction "}}}
" Function: s:find_app() {{{
" ============================================================
function! s:find_app()
  let path = ''
  return path
endfunction
" }}}

" Functions: s:get_complelist_xxx()
" ============================================================
function! s:get_complelist(dict,ArgLead) "{{{
  let list = sort(keys(a:dict))
  return filter(list, 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction "}}}
function! s:get_complelist_controller(ArgLead, CmdLine, CursorPos) "{{{
  return s:get_complelist(s:cake.get_controllers(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_model(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_models(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_view(ArgLead, CmdLine, CursorPos) "{{{
  let args = split(a:CmdLine, '\W\+')
  let view_name = get(args, 1)
  let theme_name = get(args, 2)
  let themes = s:cake.get_themes()

  if !s:cake.is_controller(expand("%:p"))
    return []
  elseif count(s:cake.get_views(s:cake.path_to_name_controller(expand("%:p"))), view_name) == 0
    return filter(sort(s:cake.get_views(s:cake.path_to_name_controller(expand("%:p")))), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  elseif !has_key(themes, theme_name)
    return filter(sort(keys(themes)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  endif
endfunction " }}}
function! s:get_complelist_controllerview(ArgLead, CmdLine, CursorPos) "{{{
  let args = split(a:CmdLine, '\W\+')
  let controller_name = util#camelize(get(args, 1))
  let view_name = get(args, 2)
  let theme_name = get(args, 3)
  let controllers = s:cake.get_controllers()
  let themes = s:cake.get_themes()

  if !has_key(controllers, controller_name)
    " Completion of the first argument.
    " Returns a list of the controller name.
    return s:get_complelist_controller(a:ArgLead, a:CmdLine, a:CursorPos)
  elseif count(s:cake.get_views(controller_name), view_name) == 0
    " Completion of the second argument.
    " Returns a list of view names.
    " The view corresponds to the first argument specified in the controller.
    return filter(sort(s:cake.get_views(controller_name)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  elseif !has_key(themes, theme_name)
    " Completion of the third argument.
    " Returns a list of theme names.
    return filter(sort(keys(themes)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  endif
endfunction " }}}
function! s:get_complelist_config(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_configs(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_component(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_components(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_shell(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_shells(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_task(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_tasks(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_behavior(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_behaviors(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_helper(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_helpers(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_testmodel(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_testmodels(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_testbehavior(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_testbehaviors(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_testcomponent(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_testcomponents(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_testcontroller(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_testcontrollers(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_testhelper(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(s:cake.get_testhelpers(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_fixture(ArgLead, CmdLine, CursorPos) "{{{
  return s:get_complelist(s:cake.get_fixtures(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_log(ArgLead, CmdLine, CursorPos) " {{{
  let list = sort(keys(g:cakephp_log))
  return filter(sort(list), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
endfunction " }}}
" ============================================================

" SECTION: Auto commands {{{
"============================================================
if s:is_initialized == 0 && exists("g:cakephp_auto_set_project") && g:cakephp_auto_set_project == 1
  autocmd VimEnter * call s:initialize('')
endif

autocmd FileType php,ctp,htmlcake call s:map_commands()
" }}}
" SECTION: Commands {{{
" ============================================================
" Initialized. If you have an argument, given that initializes the app path.
command! -n=? -complete=dir Cakephp :call s:initialize(<f-args>)

" * -> Controller
" Argument is Controller.
" When the Model or View is open, if no arguments are inferred from the currently opened file.
command! -n=* -complete=customlist,s:get_complelist_controller Ccontroller call s:cake.jump_controller('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_controller Ccontrollersp call s:cake.jump_controller('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_controller Ccontrollervsp call s:cake.jump_controller('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_controller Ccontrollertab call s:cake.jump_controller('t', <f-args>)

" * -> Model
" Argument is Model.
" When the Controller is open, if no arguments are inferred from the currently opened file.
command! -n=* -complete=customlist,s:get_complelist_model Cmodel call s:cake.jump_model('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_model Cmodelsp call s:cake.jump_model('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_model Cmodelvsp call s:cake.jump_model('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_model Cmodeltab call s:cake.jump_model('t', <f-args>)

" Controller -> View
" Argument is View (,Theme).
command! -n=+ -complete=customlist,s:get_complelist_view Cview call s:cake.jump_view('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_view Cviewsp call s:cake.jump_view('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_view Cviewvsp call s:cake.jump_view('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_view Cviewtab call s:cake.jump_view('t', <f-args>)

" * -> View
" Argument is Controller, View (,Theme).
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerview call s:cake.jump_controllerview('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerviewsp call s:cake.jump_controllerview('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerviewvsp call s:cake.jump_controllerview('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerviewtab call s:cake.jump_controllerview('t', <f-args>)

" * -> Config
" Argument is Config.
command! -n=+ -complete=customlist,s:get_complelist_config Cconfig call s:cake.jump_config('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_config Cconfigsp call s:cake.jump_config('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_config Cconfigvsp call s:cake.jump_config('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_config Cconfigtab call s:cake.jump_config('t', <f-args>)

" * -> Component
" Argument is Component.
command! -n=* -complete=customlist,s:get_complelist_component Ccomponent call s:cake.jump_component('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_component Ccomponentsp call s:cake.jump_component('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_component Ccomponentvsp call s:cake.jump_component('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_component Ccomponenttab call s:cake.jump_component('t', <f-args>)

" * -> Shell
" Argument is Shell.
command! -n=+ -complete=customlist,s:get_complelist_shell Cshell call s:cake.jump_shell('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_shell Cshellsp call s:cake.jump_shell('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_shell Cshellvsp call s:cake.jump_shell('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_shell Cshelltab call s:cake.jump_shell('t', <f-args>)

" * -> Task
" Argument is Task.
command! -n=+ -complete=customlist,s:get_complelist_task Ctask call s:cake.jump_task('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_task Ctasksp call s:cake.jump_task('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_task Ctaskvsp call s:cake.jump_task('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_task Ctasktab call s:cake.jump_task('t', <f-args>)

" * -> Behavior
" Argument is Behavior.
command! -n=* -complete=customlist,s:get_complelist_behavior Cbehavior call s:cake.jump_behavior('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_behavior Cbehaviorsp call s:cake.jump_behavior('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_behavior Cbehaviorvsp call s:cake.jump_behavior('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_behavior Cbehaviortab call s:cake.jump_behavior('t', <f-args>)

" * -> Helper
" Argument is Helper.
command! -n=* -complete=customlist,s:get_complelist_helper Chelper call s:cake.jump_helper('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_helper Chelpersp call s:cake.jump_helper('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_helper Chelpervsp call s:cake.jump_helper('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_helper Chelpertab call s:cake.jump_helper('t', <f-args>)

" * -> Test of Model
" Argument is Test of Model.
command! -n=* -complete=customlist,s:get_complelist_testmodel Ctestmodel call s:cake.jump_testmodel('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testmodel Ctestmodelsp call s:cake.jump_testmodel('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testmodel Ctestmodelvsp call s:cake.jump_testmodel('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testmodel Ctestmodeltab call s:cake.jump_testmodel('t', <f-args>)

" * -> Test of Behavior
" Argument is Test of Behavior.
command! -n=* -complete=customlist,s:get_complelist_testbehavior Ctestbehavior call s:cake.jump_testbehavior('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testbehavior Ctestbehaviorsp call s:cake.jump_testbehavior('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testbehavior Ctestbehaviorvsp call s:cake.jump_testbehavior('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testbehavior Ctestbehaviortab call s:cake.jump_testbehavior('t', <f-args>)

" * -> Test of Component
" Argument is Test of Component.
command! -n=* -complete=customlist,s:get_complelist_testcomponent Ctestcomponent call s:cake.jump_testcomponent('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcomponent Ctestcomponentsp call s:cake.jump_testcomponent('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcomponent Ctestcomponentvsp call s:cake.jump_testcomponent('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcomponent Ctestcomponenttab call s:cake.jump_testcomponent('t', <f-args>)

" * -> Test of Controller
" Argument is Test of Controller.
command! -n=* -complete=customlist,s:get_complelist_testcontroller Ctestcontroller call s:cake.jump_testcontroller('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcontroller Ctestcontrollersp call s:cake.jump_testcontroller('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcontroller Ctestcontrollervsp call s:cake.jump_testcontroller('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcontroller Ctestcontrollertab call s:cake.jump_testcontroller('t', <f-args>)

" * -> Test of Helper
" Argument is Test of Helper.
command! -n=* -complete=customlist,s:get_complelist_testhelper Ctesthelper call s:cake.jump_testhelper('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testhelper Ctesthelpersp call s:cake.jump_testhelper('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testhelper Ctesthelpervsp call s:cake.jump_testhelper('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testhelper Ctesthelpertab call s:cake.jump_testhelper('t', <f-args>)

" * -> Test of any
command! -n=0  Ctest call s:cake.jump_test('n', <f-args>)
command! -n=0  Ctestsp call s:cake.jump_test('s', <f-args>)
command! -n=0  Ctestvsp call s:cake.jump_test('v', <f-args>)
command! -n=0  Ctesttab call s:cake.jump_test('t', <f-args>)

" * -> Fixture
" Argument is Fixture.
command! -n=* -complete=customlist,s:get_complelist_fixture Cfixture call s:cake.jump_fixture('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_fixture Cfixturesp call s:cake.jump_fixture('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_fixture Cfixturevsp call s:cake.jump_fixture('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_fixture Cfixturetab call s:cake.jump_fixture('t', <f-args>)

" * -> Log
" Argument is Log name.
command! -n=1 -complete=customlist,s:get_complelist_log Clog call s:cake.tail_log(<f-args>)
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
      for i in items(s:cake.get_controllers())
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
      for i in items(s:cake.get_models())
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
        call util#echo_warning("No controller in current buffer. [Usage] :Unite cake_view:{controller-name},{controller-name}...")
        return candidates
      endif

      for i in a:context.source__controllers
        " default
        for path in split(globpath(s:cake.paths.views .util#decamelize(i) . "/", "*.ctp"), "\n")
          call add(candidates, {
                \ 'word' : '(No Theme) ' . fnamemodify(path, ":t:r"),
                \ 'kind' : 'file',
                \ 'source' : 'cake_view',
                \ 'action__path' : path,
                \ 'action__directory' : fnamemodify(path,":p:h"),
                \ })
        endfor

        " every theme
        for theme in items(s:cake.get_themes())
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
    endfunction

    function! s:unite_source_view.hooks.on_init(args, context)
      " get controller's list
      let controllers = []

      if len(a:args) == 0
        if s:cake.is_controller(expand("%:p"))
          call add(controllers, s:cake.path_to_name_controller(expand("%:p")))
        endif
      else
        for i in split(a:args[0], ",")
          if s:cake.is_controller(s:cake.name_to_path_controller(i))
            call add(controllers, i)
          elseif s:cake.is_controller(s:cake.name_to_path_controller(util#pluralize(i)))
            " try the plural form.
            call add(controllers, util#pluralize(i))
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
    for i in items(s:cake.get_behaviors())
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
    for i in items(s:cake.get_helpers())
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
    for i in items(s:cake.get_components())
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
    for i in items(s:cake.get_fixtures())
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
    for i in items(s:cake.get_configs())
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
    for i in items(s:cake.get_shells())
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
    for i in items(s:cake.get_tasks())
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
