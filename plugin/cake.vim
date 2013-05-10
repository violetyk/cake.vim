" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.
" Last Change: 2013/05/10

if exists('g:loaded_cake_vim')
  finish
endif
if v:version < 703
  echoerr "[cake.vim] this plugin requires vim >= 703 Thank you for trying to use this plugin."
  finish
endif
let g:loaded_cake_vim = 1

if exists("g:cakephp_auto_set_project")
  echo '[cake.vim] g:cakephp_auto_set_project has been deprecated. Please use g:cakephp_enable_fix_mode instead.'
  if g:cakephp_auto_set_project == 1
    let g:cakephp_enable_fix_mode = 1
  endif
endif

let s:save_cpo = &cpo
set cpo&vim

" SECTION: Optional Settings
" let g:cakephp_enable_fix_mode = 1
" let g:cakephp_app             = "/path/to/cakephp_root/app/"
" let g:cakephp_use_theme       = "admin"
" let g:cakephp_core_path       = "/path/to/cakephp_core/"
" let g:cakephp_abbreviations     = {
      " \ 'td'  : '$this->data',
      " \ 'trd' : '$this->request->data',
      " \ 'ta'  : '$this->alias',
      " \ }

" SECTION: Global Variables {{{
" fix setting of the app.
let g:cakevim_version                   = '2.11'
let g:cakephp_enable_fix_mode           = get(g:, 'cakephp_enable_fix_mode', 0)
let g:cakephp_app                       = get(g:, 'cakephp_app', '')
let g:cakephp_use_theme                 = get(g:, 'cakephp_use_theme', '')
let g:cakephp_core_path                 = get(g:, 'cakephp_core_path', '')
" automatically look for app and set it
let g:cakephp_enable_auto_mode          = get(g:, 'cakephp_enable_auto_mode', (g:cakephp_enable_fix_mode)? 0 : 1)
let g:cakephp_enable_abbreviations      = get(g:, 'cakephp_enable_abbreviations', 0)
let g:cakephp_log_window_size           = get(g:, 'cakephp_log_window_size', 15)
let g:cakephp_db_type                   = get(g:, 'cakephp_db_type', 'MySQL')
let g:cakephp_db_port                   = get(g:, 'cakephp_db_port', 3306)
let g:cakephp_db_buffer_lines           = get(g:, 'cakephp_db_buffer_lines', 20)
let g:cakephp_app_config_file           = get(g:, 'cakephp_app_config_file', '.cake')
let g:cakephp_keybind_vsplit_gf         = get(g:, 'cakephp_keybind_vsplit_gf', 'gs')
let g:cakephp_log                       = get(g:, 'cakephp_log', {
                                              \ 'debug' : '',
                                              \ 'error' : '',
                                              \ 'query' : '/var/log/mysql/query.log',
                                              \ 'access': '/usr/local/apache2/logs/access_log'
                                              \ })

let g:cake = {}
" }}}
" SECTION: Auto commands {{{
augroup detect_cakephp_project
  autocmd!
  autocmd VimEnter * if g:cakephp_enable_fix_mode | call cake#init_app('') | endif
  autocmd BufEnter *.php,*.ctp,*.css,*.js if g:cakephp_enable_auto_mode | call cake#autoset_app() | endif
  autocmd FileType php,ctp,htmlcake call cake#init_buffer()
augroup END

" }}}
" SECTION: Commands {{{
" ============================================================
command! -n=0  Cakeinfo call cake#info()

" Initialized. If you have an argument, given that initializes the app path.
command! -n=? -complete=dir Cakephp :call cake#init_app(<f-args>)

" * -> Controller
" Argument is Controller.
" When the Model or View is open, if no arguments are inferred from the currently opened file.
command! -n=* -complete=customlist,cake#get_complelist_controller Ccontroller call g:cake.jump_controller('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_controller Ccontrollersp call g:cake.jump_controller('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_controller Ccontrollervsp call g:cake.jump_controller('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_controller Ccontrollertab call g:cake.jump_controller('t', <f-args>)

" * -> Model
" Argument is Model.
" When the Controller is open, if no arguments are inferred from the currently opened file.
command! -n=* -complete=customlist,cake#get_complelist_model Cmodel call g:cake.jump_model('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_model Cmodelsp call g:cake.jump_model('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_model Cmodelvsp call g:cake.jump_model('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_model Cmodeltab call g:cake.jump_model('t', <f-args>)

" Controller -> View
" Argument is View (,Theme).
" When the Controller is open, if no arguments are inferred from the currently line.
command! -n=* -complete=customlist,cake#get_complelist_view Cview call g:cake.jump_view('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_view Cviewsp call g:cake.jump_view('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_view Cviewvsp call g:cake.jump_view('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_view Cviewtab call g:cake.jump_view('t', <f-args>)

" * -> View
" Argument is Controller, View (,Theme).
command! -n=+ -complete=customlist,cake#get_complelist_controllerview Ccontrollerview call g:cake.jump_controllerview('n', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_controllerview Ccontrollerviewsp call g:cake.jump_controllerview('s', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_controllerview Ccontrollerviewvsp call g:cake.jump_controllerview('v', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_controllerview Ccontrollerviewtab call g:cake.jump_controllerview('t', <f-args>)

" * -> Config
" Argument is Config.
command! -n=+ -complete=customlist,cake#get_complelist_config Cconfig call g:cake.jump_config('n', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_config Cconfigsp call g:cake.jump_config('s', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_config Cconfigvsp call g:cake.jump_config('v', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_config Cconfigtab call g:cake.jump_config('t', <f-args>)

" * -> Component
" Argument is Component.
command! -n=* -complete=customlist,cake#get_complelist_component Ccomponent call g:cake.jump_component('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_component Ccomponentsp call g:cake.jump_component('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_component Ccomponentvsp call g:cake.jump_component('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_component Ccomponenttab call g:cake.jump_component('t', <f-args>)

" * -> Shell
" Argument is Shell.
command! -n=+ -complete=customlist,cake#get_complelist_shell Cshell call g:cake.jump_shell('n', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_shell Cshellsp call g:cake.jump_shell('s', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_shell Cshellvsp call g:cake.jump_shell('v', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_shell Cshelltab call g:cake.jump_shell('t', <f-args>)

" * -> Task
" Argument is Task.
command! -n=+ -complete=customlist,cake#get_complelist_task Ctask call g:cake.jump_task('n', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_task Ctasksp call g:cake.jump_task('s', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_task Ctaskvsp call g:cake.jump_task('v', <f-args>)
command! -n=+ -complete=customlist,cake#get_complelist_task Ctasktab call g:cake.jump_task('t', <f-args>)

" * -> Behavior
" Argument is Behavior.
command! -n=* -complete=customlist,cake#get_complelist_behavior Cbehavior call g:cake.jump_behavior('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_behavior Cbehaviorsp call g:cake.jump_behavior('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_behavior Cbehaviorvsp call g:cake.jump_behavior('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_behavior Cbehaviortab call g:cake.jump_behavior('t', <f-args>)

" * -> Helper
" Argument is Helper.
command! -n=* -complete=customlist,cake#get_complelist_helper Chelper call g:cake.jump_helper('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_helper Chelpersp call g:cake.jump_helper('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_helper Chelpervsp call g:cake.jump_helper('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_helper Chelpertab call g:cake.jump_helper('t', <f-args>)

" * -> Test of Model
" Argument is Test of Model.
command! -n=* -complete=customlist,cake#get_complelist_testmodel Ctestmodel call g:cake.jump_testmodel('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testmodel Ctestmodelsp call g:cake.jump_testmodel('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testmodel Ctestmodelvsp call g:cake.jump_testmodel('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testmodel Ctestmodeltab call g:cake.jump_testmodel('t', <f-args>)

" * -> Test of Behavior
" Argument is Test of Behavior.
command! -n=* -complete=customlist,cake#get_complelist_testbehavior Ctestbehavior call g:cake.jump_testbehavior('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testbehavior Ctestbehaviorsp call g:cake.jump_testbehavior('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testbehavior Ctestbehaviorvsp call g:cake.jump_testbehavior('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testbehavior Ctestbehaviortab call g:cake.jump_testbehavior('t', <f-args>)

" * -> Test of Component
" Argument is Test of Component.
command! -n=* -complete=customlist,cake#get_complelist_testcomponent Ctestcomponent call g:cake.jump_testcomponent('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testcomponent Ctestcomponentsp call g:cake.jump_testcomponent('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testcomponent Ctestcomponentvsp call g:cake.jump_testcomponent('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testcomponent Ctestcomponenttab call g:cake.jump_testcomponent('t', <f-args>)

" * -> Test of Controller
" Argument is Test of Controller.
command! -n=* -complete=customlist,cake#get_complelist_testcontroller Ctestcontroller call g:cake.jump_testcontroller('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testcontroller Ctestcontrollersp call g:cake.jump_testcontroller('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testcontroller Ctestcontrollervsp call g:cake.jump_testcontroller('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testcontroller Ctestcontrollertab call g:cake.jump_testcontroller('t', <f-args>)

" * -> Test of Helper
" Argument is Test of Helper.
command! -n=* -complete=customlist,cake#get_complelist_testhelper Ctesthelper call g:cake.jump_testhelper('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testhelper Ctesthelpersp call g:cake.jump_testhelper('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testhelper Ctesthelpervsp call g:cake.jump_testhelper('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_testhelper Ctesthelpertab call g:cake.jump_testhelper('t', <f-args>)

" * -> Test of any
command! -n=0  Ctest call g:cake.jump_test('n', <f-args>)
command! -n=0  Ctestsp call g:cake.jump_test('s', <f-args>)
command! -n=0  Ctestvsp call g:cake.jump_test('v', <f-args>)
command! -n=0  Ctesttab call g:cake.jump_test('t', <f-args>)

" * -> Fixture
" Argument is Fixture.
command! -n=* -complete=customlist,cake#get_complelist_fixture Cfixture call g:cake.jump_fixture('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_fixture Cfixturesp call g:cake.jump_fixture('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_fixture Cfixturevsp call g:cake.jump_fixture('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_fixture Cfixturetab call g:cake.jump_fixture('t', <f-args>)

" * -> Log
" Argument is Log name.
command! -n=1 -complete=customlist,cake#get_complelist_log Clog call g:cake.tail_log(<f-args>)

" * -> CakePHP Core Libraries.
command! -n=* -complete=customlist,cake#get_complelist_lib Clib call g:cake.jump_lib('n', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_lib Clibsp call g:cake.jump_lib('s', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_lib Clibvsp call g:cake.jump_lib('v', <f-args>)
command! -n=* -complete=customlist,cake#get_complelist_lib Clibtab call g:cake.jump_lib('t', <f-args>)

" Describe Table.
command! -n=? -complete=customlist,cake#get_complelist_model Cdesc call g:cake.describe_table(<f-args>)

command! -n=0 -range Cquickrun :<line1>,<line2>call g:cake.quickrun()

" Run Bake
command! -n=* -complete=customlist,cake#get_complelist_bake Cbake call g:cake.bake_interactive(<f-args>)

" Run Test
command! -n=0  Ctestrun call g:cake.test(expand('%:p'))
" }}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
