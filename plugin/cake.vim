" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.
" Last Change: 2013/05/24

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
let g:cakevim_version                   = '2.11.1'
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
command! -n=* -complete=customlist,cake#get_complelist_controller Ccontroller    if exists('g:cake.jump_controller') | call g:cake.jump_controller('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_controller Ccontrollersp  if exists('g:cake.jump_controller') | call g:cake.jump_controller('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_controller Ccontrollervsp if exists('g:cake.jump_controller') | call g:cake.jump_controller('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_controller Ccontrollertab if exists('g:cake.jump_controller') | call g:cake.jump_controller('t', <f-args>) | endif

" * -> Model
" Argument is Model.
" When the Controller is open, if no arguments are inferred from the currently opened file.
command! -n=* -complete=customlist,cake#get_complelist_model Cmodel    if exists('g:cake.jump_model') | call g:cake.jump_model('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_model Cmodelsp  if exists('g:cake.jump_model') | call g:cake.jump_model('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_model Cmodelvsp if exists('g:cake.jump_model') | call g:cake.jump_model('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_model Cmodeltab if exists('g:cake.jump_model') | call g:cake.jump_model('t', <f-args>) | endif

" Controller -> View
" Argument is View (,Theme).
" When the Controller is open, if no arguments are inferred from the currently line.
command! -n=* -complete=customlist,cake#get_complelist_view Cview    if exists('g:cake.jump_view') | call g:cake.jump_view('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_view Cviewsp  if exists('g:cake.jump_view') | call g:cake.jump_view('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_view Cviewvsp if exists('g:cake.jump_view') | call g:cake.jump_view('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_view Cviewtab if exists('g:cake.jump_view') | call g:cake.jump_view('t', <f-args>) | endif

" * -> View
" Argument is Controller, View (,Theme).
command! -n=+ -complete=customlist,cake#get_complelist_controllerview Ccontrollerview    if exists('g:cake.jump_controllerview') | call g:cake.jump_controllerview('n', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_controllerview Ccontrollerviewsp  if exists('g:cake.jump_controllerview') | call g:cake.jump_controllerview('s', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_controllerview Ccontrollerviewvsp if exists('g:cake.jump_controllerview') | call g:cake.jump_controllerview('v', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_controllerview Ccontrollerviewtab if exists('g:cake.jump_controllerview') | call g:cake.jump_controllerview('t', <f-args>) | endif

" * -> Config
" Argument is Config.
command! -n=+ -complete=customlist,cake#get_complelist_config Cconfig    if exists('g:cake.jump_config') | call g:cake.jump_config('n', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_config Cconfigsp  if exists('g:cake.jump_config') | call g:cake.jump_config('s', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_config Cconfigvsp if exists('g:cake.jump_config') | call g:cake.jump_config('v', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_config Cconfigtab if exists('g:cake.jump_config') | call g:cake.jump_config('t', <f-args>) | endif

" * -> Component
" Argument is Component.
command! -n=* -complete=customlist,cake#get_complelist_component Ccomponent    if exists('g:cake.jump_component') | call g:cake.jump_component('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_component Ccomponentsp  if exists('g:cake.jump_component') | call g:cake.jump_component('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_component Ccomponentvsp if exists('g:cake.jump_component') | call g:cake.jump_component('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_component Ccomponenttab if exists('g:cake.jump_component') | call g:cake.jump_component('t', <f-args>) | endif

" * -> Shell
" Argument is Shell.
command! -n=+ -complete=customlist,cake#get_complelist_shell Cshell    if exists('g:cake.jump_shell') | call g:cake.jump_shell('n', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_shell Cshellsp  if exists('g:cake.jump_shell') | call g:cake.jump_shell('s', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_shell Cshellvsp if exists('g:cake.jump_shell') | call g:cake.jump_shell('v', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_shell Cshelltab if exists('g:cake.jump_shell') | call g:cake.jump_shell('t', <f-args>) | endif

" * -> Task
" Argument is Task.
command! -n=+ -complete=customlist,cake#get_complelist_task Ctask    if exists('g:cake.jump_task') | call g:cake.jump_task('n', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_task Ctasksp  if exists('g:cake.jump_task') | call g:cake.jump_task('s', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_task Ctaskvsp if exists('g:cake.jump_task') | call g:cake.jump_task('v', <f-args>) | endif
command! -n=+ -complete=customlist,cake#get_complelist_task Ctasktab if exists('g:cake.jump_task') | call g:cake.jump_task('t', <f-args>) | endif

" * -> Behavior
" Argument is Behavior.
command! -n=* -complete=customlist,cake#get_complelist_behavior Cbehavior    if exists('g:cake.jump_behavior') | call g:cake.jump_behavior('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_behavior Cbehaviorsp  if exists('g:cake.jump_behavior') | call g:cake.jump_behavior('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_behavior Cbehaviorvsp if exists('g:cake.jump_behavior') | call g:cake.jump_behavior('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_behavior Cbehaviortab if exists('g:cake.jump_behavior') | call g:cake.jump_behavior('t', <f-args>) | endif

" * -> Helper
" Argument is Helper.
command! -n=* -complete=customlist,cake#get_complelist_helper Chelper    if exists('g:cake.jump_helper') | call g:cake.jump_helper('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_helper Chelpersp  if exists('g:cake.jump_helper') | call g:cake.jump_helper('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_helper Chelpervsp if exists('g:cake.jump_helper') | call g:cake.jump_helper('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_helper Chelpertab if exists('g:cake.jump_helper') | call g:cake.jump_helper('t', <f-args>) | endif

" * -> Test of Model
" Argument is Test of Model.
command! -n=* -complete=customlist,cake#get_complelist_testmodel Ctestmodel    if exists('g:cake.jump_testmodel') | call g:cake.jump_testmodel('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testmodel Ctestmodelsp  if exists('g:cake.jump_testmodel') | call g:cake.jump_testmodel('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testmodel Ctestmodelvsp if exists('g:cake.jump_testmodel') | call g:cake.jump_testmodel('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testmodel Ctestmodeltab if exists('g:cake.jump_testmodel') | call g:cake.jump_testmodel('t', <f-args>) | endif

" * -> Test of Behavior
" Argument is Test of Behavior.
command! -n=* -complete=customlist,cake#get_complelist_testbehavior Ctestbehavior    if exists('g:cake.jump_testbehavior') | call g:cake.jump_testbehavior('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testbehavior Ctestbehaviorsp  if exists('g:cake.jump_testbehavior') | call g:cake.jump_testbehavior('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testbehavior Ctestbehaviorvsp if exists('g:cake.jump_testbehavior') | call g:cake.jump_testbehavior('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testbehavior Ctestbehaviortab if exists('g:cake.jump_testbehavior') | call g:cake.jump_testbehavior('t', <f-args>) | endif

" * -> Test of Component
" Argument is Test of Component.
command! -n=* -complete=customlist,cake#get_complelist_testcomponent Ctestcomponent    if exists('g:cake.jump_testcomponent') | call g:cake.jump_testcomponent('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testcomponent Ctestcomponentsp  if exists('g:cake.jump_testcomponent') | call g:cake.jump_testcomponent('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testcomponent Ctestcomponentvsp if exists('g:cake.jump_testcomponent') | call g:cake.jump_testcomponent('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testcomponent Ctestcomponenttab if exists('g:cake.jump_testcomponent') | call g:cake.jump_testcomponent('t', <f-args>) | endif

" * -> Test of Controller
" Argument is Test of Controller.
command! -n=* -complete=customlist,cake#get_complelist_testcontroller Ctestcontroller    if exists('g:cake.jump_testcontroller') | call g:cake.jump_testcontroller('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testcontroller Ctestcontrollersp  if exists('g:cake.jump_testcontroller') | call g:cake.jump_testcontroller('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testcontroller Ctestcontrollervsp if exists('g:cake.jump_testcontroller') | call g:cake.jump_testcontroller('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testcontroller Ctestcontrollertab if exists('g:cake.jump_testcontroller') | call g:cake.jump_testcontroller('t', <f-args>) | endif

" * -> Test of Helper
" Argument is Test of Helper.
command! -n=* -complete=customlist,cake#get_complelist_testhelper Ctesthelper    if exists('g:cake.jump_testhelper') | call g:cake.jump_testhelper('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testhelper Ctesthelpersp  if exists('g:cake.jump_testhelper') | call g:cake.jump_testhelper('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testhelper Ctesthelpervsp if exists('g:cake.jump_testhelper') | call g:cake.jump_testhelper('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_testhelper Ctesthelpertab if exists('g:cake.jump_testhelper') | call g:cake.jump_testhelper('t', <f-args>) | endif

" * -> Test of any
command! -n=0  Ctest    if exists('g:cake.jump_test') | call g:cake.jump_test('n', <f-args>) | endif
command! -n=0  Ctestsp  if exists('g:cake.jump_test') | call g:cake.jump_test('s', <f-args>) | endif
command! -n=0  Ctestvsp if exists('g:cake.jump_test') | call g:cake.jump_test('v', <f-args>) | endif
command! -n=0  Ctesttab if exists('g:cake.jump_test') | call g:cake.jump_test('t', <f-args>) | endif

" * -> Fixture
" Argument is Fixture.
command! -n=* -complete=customlist,cake#get_complelist_fixture Cfixture    if exists('g:cake.jump_fixture') | call g:cake.jump_fixture('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_fixture Cfixturesp  if exists('g:cake.jump_fixture') | call g:cake.jump_fixture('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_fixture Cfixturevsp if exists('g:cake.jump_fixture') | call g:cake.jump_fixture('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_fixture Cfixturetab if exists('g:cake.jump_fixture') | call g:cake.jump_fixture('t', <f-args>) | endif

" * -> Log
" Argument is Log name.
command! -n=1 -complete=customlist,cake#get_complelist_log Clog if exists('g:cake.tail_log') | call g:cake.tail_log(<f-args>) | endif

" * -> CakePHP Core Libraries.
command! -n=* -complete=customlist,cake#get_complelist_lib Clib    if exists('g:cake.jump_lib') | call g:cake.jump_lib('n', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_lib Clibsp  if exists('g:cake.jump_lib') | call g:cake.jump_lib('s', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_lib Clibvsp if exists('g:cake.jump_lib') | call g:cake.jump_lib('v', <f-args>) | endif
command! -n=* -complete=customlist,cake#get_complelist_lib Clibtab if exists('g:cake.jump_lib') | call g:cake.jump_lib('t', <f-args>) | endif

" Describe Table.
command! -n=? -complete=customlist,cake#get_complelist_model Cdesc if exists('g:cake.describe_table') | call g:cake.describe_table(<f-args>) | endif

command! -n=0 -range Cquickrun if exists('g:cake.quickrun') | :<line1>,<line2>call g:cake.quickrun() | endif

" Run Bake
command! -n=* -complete=customlist,cake#get_complelist_bake Cbake if exists('g:cake.bake_interactive') | call g:cake.bake_interactive(<f-args>) | endif

" Run Test
command! -n=0  Ctestrun if exists('g:cake.test') | call g:cake.test(expand('%:p')) | endif
" }}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
