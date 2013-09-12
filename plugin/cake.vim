" cake.vim - Utility for CakePHP developpers.
" Maintainer:  Yuhei Kagaya <yuhei.kagaya@gmail.com>
" License:     This file is placed in the public domain.
" Last Change: 2013/09/12

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
let g:cakephp_no_default_keymappings    = get(g:, 'cakephp_no_default_keymappings', 0)
let g:cakephp_gf_fallback_n             = get(g:, 'cakephp_gf_fallback_n', "normal! gf")
let g:cakephp_gf_fallback_s             = get(g:, 'cakephp_gf_fallback_s', "normal! \<C-w>f")
let g:cakephp_gf_fallback_t             = get(g:, 'cakephp_gf_fallback_t', "normal! \<C-w>gf")
let g:cakephp_test_window_vertical      = get(g:, 'cakephp_test_window_vertical', 0)
let g:cakephp_test_window_height        = get(g:, 'cakephp_test_window_height', 15)
let g:cakephp_test_window_width         = get(g:, 'cakephp_test_window_width', 70)
" }}}
" SECTION: Auto commands {{{
augroup detect_cakephp_project
  autocmd!
  autocmd VimEnter * if g:cakephp_enable_fix_mode | call cake#init_app('') | endif
  autocmd BufEnter *.php,*.ctp,*.css,*.js if g:cakephp_enable_auto_mode | call cake#autoset_app() | endif | call cake#init_buffer()
augroup END

" }}}
" SECTION: Commands {{{
" ============================================================
command! -n=0  Cakeinfo call cake#info()

" Initialized. If you have an argument, given that initializes the app path.
command! -n=? -complete=dir Cakephp :call cake#init_app(<f-args>)

function! s:register_commands() "{{{
  let jump_options = {
        \ 'n' : '',
        \ 's' : 'sp',
        \ 'v' : 'vsp',
        \ 't' : 'tab'
        \}
  let jump_resources = {
        \ 'controller'     : {'arg' : '*', 'complete_func' : 1},
        \ 'model'          : {'arg' : '*', 'complete_func' : 1},
        \ 'view'           : {'arg' : '*', 'complete_func' : 1},
        \ 'controllerview' : {'arg' : '+', 'complete_func' : 1},
        \ 'config'         : {'arg' : '+', 'complete_func' : 1},
        \ 'component'      : {'arg' : '*', 'complete_func' : 1},
        \ 'shell'          : {'arg' : '+', 'complete_func' : 1},
        \ 'task'           : {'arg' : '+', 'complete_func' : 1},
        \ 'behavior'       : {'arg' : '*', 'complete_func' : 1},
        \ 'helper'         : {'arg' : '*', 'complete_func' : 1},
        \ 'testmodel'      : {'arg' : '*', 'complete_func' : 1},
        \ 'testbehavior'   : {'arg' : '*', 'complete_func' : 1},
        \ 'testcomponent'  : {'arg' : '*', 'complete_func' : 1},
        \ 'testcontroller' : {'arg' : '*', 'complete_func' : 1},
        \ 'testhelper'     : {'arg' : '*', 'complete_func' : 1},
        \ 'test'           : {'arg' : '0', 'complete_func' : 0},
        \ 'fixture'        : {'arg' : '*', 'complete_func' : 1},
        \ 'lib'            : {'arg' : '*', 'complete_func' : 1},
        \ 'core'           : {'arg' : '*', 'complete_func' : 1}
        \}

  for r in items(jump_resources)
    let resource        = get(r, 0)
    let resource_option = get(r, 1)

    for o in items(jump_options)
      let split_option = get(o, 0)
      let split_suffix = get(o, 1)
      if resource_option.complete_func == 1
        let cmd = printf(
              \ ":command! -n=%s -complete=customlist,cake#get_complelist_%s C%s%s if exists('g:cake.jump_%s') | call g:cake.jump_%s('%s', <f-args>) | endif",
              \ resource_option.arg,
              \ resource,
              \ resource,
              \ split_suffix,
              \ resource,
              \ resource,
              \ split_option
              \ )
      else
        let cmd = printf(
              \ ":command! -n=%s -complete=customlist, C%s%s if exists('g:cake.jump_%s') | call g:cake.jump_%s('%s', <f-args>) | endif",
              \ resource_option.arg,
              \ resource,
              \ split_suffix,
              \ resource,
              \ resource,
              \ split_option
              \ )
      endif
      execute cmd
    endfor

  endfor
endfunction "}}}

call s:register_commands()

command! -n=1 -complete=customlist,cake#get_complelist_log Clog if exists('g:cake.tail_log') | call g:cake.tail_log(<f-args>) | endif
command! -n=? -complete=customlist,cake#get_complelist_model Cdesc if exists('g:cake.describe_table') | call g:cake.describe_table(<f-args>) | endif
command! -n=0 -range Cquickrun if exists('g:cake.quickrun') | :<line1>,<line2>call g:cake.quickrun() | endif
command! -n=* -complete=customlist,cake#get_complelist_bake Cbake if exists('g:cake.bake_interactive') | call g:cake.bake_interactive(<f-args>) | endif
command! -n=? -complete=customlist,cake#get_complelist_testmethod Ctestrun if exists('g:cake.run_test') | call g:cake.run_test(expand('%:p'), <f-args>) | endif
command! -n=0 Ctestrunmethod if exists('g:cake.run_current_testmethod') | call g:cake.run_current_testmethod() | endif

" }}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
