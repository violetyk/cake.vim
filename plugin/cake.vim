" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.
" Last Change: 2011/12/17
" Version:     2.1.1

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

let g:cake = {}
" }}}
" SECTION: Script Variables {{{
" ============================================================
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
    let g:cake = cake#cake20#factory(a:path_app)
    let s:is_initialized = 1
    call s:map_commands()
  elseif isdirectory(a:path_app . 'controllers') && isdirectory(a:path_app . 'models') && isdirectory(a:path_app . 'views')
    let g:cake = cake#cake13#factory(a:path_app)
    let s:is_initialized = 1
    call s:map_commands()
  else
    call cake#util#echo_warning("[cake.vim] Please set g:cakephp_app or :Cakephp {app}.")
    let s:is_initialized = 0
    return
  endif

  call g:cake.set_log(g:cakephp_log)
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
  call g:cake.smart_jump(a:option)
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
  return s:get_complelist(g:cake.get_controllers(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_model(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_models(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_view(ArgLead, CmdLine, CursorPos) "{{{
  let args = split(a:CmdLine, '\W\+')
  let view_name = get(args, 1)
  let theme_name = get(args, 2)
  let themes = g:cake.get_themes()

  if !g:cake.is_controller(expand("%:p"))
    return []
  elseif count(g:cake.get_views(g:cake.path_to_name_controller(expand("%:p"))), view_name) == 0
    return filter(sort(g:cake.get_views(g:cake.path_to_name_controller(expand("%:p")))), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  elseif !has_key(themes, theme_name)
    return filter(sort(keys(themes)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  endif
endfunction " }}}
function! s:get_complelist_controllerview(ArgLead, CmdLine, CursorPos) "{{{
  let args = split(a:CmdLine, '\W\+')
  let controller_name = cake#util#camelize(get(args, 1))
  let view_name = get(args, 2)
  let theme_name = get(args, 3)
  let controllers = g:cake.get_controllers()
  let themes = g:cake.get_themes()

  if !has_key(controllers, controller_name)
    " Completion of the first argument.
    " Returns a list of the controller name.
    return s:get_complelist_controller(a:ArgLead, a:CmdLine, a:CursorPos)
  elseif count(g:cake.get_views(controller_name), view_name) == 0
    " Completion of the second argument.
    " Returns a list of view names.
    " The view corresponds to the first argument specified in the controller.
    return filter(sort(g:cake.get_views(controller_name)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  elseif !has_key(themes, theme_name)
    " Completion of the third argument.
    " Returns a list of theme names.
    return filter(sort(keys(themes)), 'v:val =~ "^'. fnameescape(a:ArgLead) . '"')
  endif
endfunction " }}}
function! s:get_complelist_config(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_configs(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_component(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_components(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_shell(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_shells(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_task(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_tasks(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_behavior(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_behaviors(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_helper(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_helpers(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_testmodel(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_testmodels(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_testbehavior(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_testbehaviors(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_testcomponent(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_testcomponents(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_testcontroller(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_testcontrollers(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_testhelper(ArgLead, CmdLine, CursorPos) " {{{
  return s:get_complelist(g:cake.get_testhelpers(), a:ArgLead)
endfunction " }}}
function! s:get_complelist_fixture(ArgLead, CmdLine, CursorPos) "{{{
  return s:get_complelist(g:cake.get_fixtures(), a:ArgLead)
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
command! -n=* -complete=customlist,s:get_complelist_controller Ccontroller call g:cake.jump_controller('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_controller Ccontrollersp call g:cake.jump_controller('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_controller Ccontrollervsp call g:cake.jump_controller('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_controller Ccontrollertab call g:cake.jump_controller('t', <f-args>)

" * -> Model
" Argument is Model.
" When the Controller is open, if no arguments are inferred from the currently opened file.
command! -n=* -complete=customlist,s:get_complelist_model Cmodel call g:cake.jump_model('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_model Cmodelsp call g:cake.jump_model('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_model Cmodelvsp call g:cake.jump_model('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_model Cmodeltab call g:cake.jump_model('t', <f-args>)

" Controller -> View
" Argument is View (,Theme).
command! -n=+ -complete=customlist,s:get_complelist_view Cview call g:cake.jump_view('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_view Cviewsp call g:cake.jump_view('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_view Cviewvsp call g:cake.jump_view('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_view Cviewtab call g:cake.jump_view('t', <f-args>)

" * -> View
" Argument is Controller, View (,Theme).
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerview call g:cake.jump_controllerview('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerviewsp call g:cake.jump_controllerview('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerviewvsp call g:cake.jump_controllerview('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_controllerview Ccontrollerviewtab call g:cake.jump_controllerview('t', <f-args>)

" * -> Config
" Argument is Config.
command! -n=+ -complete=customlist,s:get_complelist_config Cconfig call g:cake.jump_config('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_config Cconfigsp call g:cake.jump_config('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_config Cconfigvsp call g:cake.jump_config('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_config Cconfigtab call g:cake.jump_config('t', <f-args>)

" * -> Component
" Argument is Component.
command! -n=* -complete=customlist,s:get_complelist_component Ccomponent call g:cake.jump_component('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_component Ccomponentsp call g:cake.jump_component('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_component Ccomponentvsp call g:cake.jump_component('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_component Ccomponenttab call g:cake.jump_component('t', <f-args>)

" * -> Shell
" Argument is Shell.
command! -n=+ -complete=customlist,s:get_complelist_shell Cshell call g:cake.jump_shell('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_shell Cshellsp call g:cake.jump_shell('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_shell Cshellvsp call g:cake.jump_shell('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_shell Cshelltab call g:cake.jump_shell('t', <f-args>)

" * -> Task
" Argument is Task.
command! -n=+ -complete=customlist,s:get_complelist_task Ctask call g:cake.jump_task('n', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_task Ctasksp call g:cake.jump_task('s', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_task Ctaskvsp call g:cake.jump_task('v', <f-args>)
command! -n=+ -complete=customlist,s:get_complelist_task Ctasktab call g:cake.jump_task('t', <f-args>)

" * -> Behavior
" Argument is Behavior.
command! -n=* -complete=customlist,s:get_complelist_behavior Cbehavior call g:cake.jump_behavior('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_behavior Cbehaviorsp call g:cake.jump_behavior('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_behavior Cbehaviorvsp call g:cake.jump_behavior('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_behavior Cbehaviortab call g:cake.jump_behavior('t', <f-args>)

" * -> Helper
" Argument is Helper.
command! -n=* -complete=customlist,s:get_complelist_helper Chelper call g:cake.jump_helper('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_helper Chelpersp call g:cake.jump_helper('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_helper Chelpervsp call g:cake.jump_helper('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_helper Chelpertab call g:cake.jump_helper('t', <f-args>)

" * -> Test of Model
" Argument is Test of Model.
command! -n=* -complete=customlist,s:get_complelist_testmodel Ctestmodel call g:cake.jump_testmodel('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testmodel Ctestmodelsp call g:cake.jump_testmodel('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testmodel Ctestmodelvsp call g:cake.jump_testmodel('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testmodel Ctestmodeltab call g:cake.jump_testmodel('t', <f-args>)

" * -> Test of Behavior
" Argument is Test of Behavior.
command! -n=* -complete=customlist,s:get_complelist_testbehavior Ctestbehavior call g:cake.jump_testbehavior('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testbehavior Ctestbehaviorsp call g:cake.jump_testbehavior('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testbehavior Ctestbehaviorvsp call g:cake.jump_testbehavior('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testbehavior Ctestbehaviortab call g:cake.jump_testbehavior('t', <f-args>)

" * -> Test of Component
" Argument is Test of Component.
command! -n=* -complete=customlist,s:get_complelist_testcomponent Ctestcomponent call g:cake.jump_testcomponent('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcomponent Ctestcomponentsp call g:cake.jump_testcomponent('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcomponent Ctestcomponentvsp call g:cake.jump_testcomponent('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcomponent Ctestcomponenttab call g:cake.jump_testcomponent('t', <f-args>)

" * -> Test of Controller
" Argument is Test of Controller.
command! -n=* -complete=customlist,s:get_complelist_testcontroller Ctestcontroller call g:cake.jump_testcontroller('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcontroller Ctestcontrollersp call g:cake.jump_testcontroller('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcontroller Ctestcontrollervsp call g:cake.jump_testcontroller('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testcontroller Ctestcontrollertab call g:cake.jump_testcontroller('t', <f-args>)

" * -> Test of Helper
" Argument is Test of Helper.
command! -n=* -complete=customlist,s:get_complelist_testhelper Ctesthelper call g:cake.jump_testhelper('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testhelper Ctesthelpersp call g:cake.jump_testhelper('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testhelper Ctesthelpervsp call g:cake.jump_testhelper('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_testhelper Ctesthelpertab call g:cake.jump_testhelper('t', <f-args>)

" * -> Test of any
command! -n=0  Ctest call g:cake.jump_test('n', <f-args>)
command! -n=0  Ctestsp call g:cake.jump_test('s', <f-args>)
command! -n=0  Ctestvsp call g:cake.jump_test('v', <f-args>)
command! -n=0  Ctesttab call g:cake.jump_test('t', <f-args>)

" * -> Fixture
" Argument is Fixture.
command! -n=* -complete=customlist,s:get_complelist_fixture Cfixture call g:cake.jump_fixture('n', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_fixture Cfixturesp call g:cake.jump_fixture('s', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_fixture Cfixturevsp call g:cake.jump_fixture('v', <f-args>)
command! -n=* -complete=customlist,s:get_complelist_fixture Cfixturetab call g:cake.jump_fixture('t', <f-args>)

" * -> Log
" Argument is Log name.
command! -n=1 -complete=customlist,s:get_complelist_log Clog call g:cake.tail_log(<f-args>)
" }}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
