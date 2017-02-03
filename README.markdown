# cake.vim
Utility for CakePHP developers. Provides the ability to easily jump between files.

## Requirements
- Vim ver.7.3 or heigher
- CakePHP ver.1.3.x or ver.2.x

## Quick Start
1. Installation
Download, unzip, put under the ~/.vim directory.  
If you are using [Vundle](http://github.com/gmarik/vundle),as follows:

     ```vim
     :BundleInstall violetyk/cake.vim
     ```
2. Launch `vim`, specify the application directory of CakePHP.

     ```vim
     :CakePHP /path/to/cakephp_app_directory
     ```

3. Open the file as follows:

     ```vim
     :Ccontroller {controller-name}
     ```

- Argument that you specify in the command `{controller-name}`, you can tab-completion.
- You can horizontal split, vertical split, also be open in the tab. Add sp, vsp, and tab to the each command.
- Multiple arguments can be specified.

     ```vim
     :Ccontrollersp {controller-name} {controller-name} ...
     :Ccontrollervsp {controller-name} {controller-name} ...
     :Ccontrollertab {controller-name} {controller-name} ...
     ```

## Jump Command List
No arguments : If you do not specify arguments, guess depending on the type of the current buffer.

| Target | Command | Multiple arguments | No arguments |
| --- | --- | :---: | --- |
| Controller|`:Ccontroller {controller-name}`| ok | View / Model / ControllerTestCase |
| Model|`:Cmodel {model-name}`| ok | Controller / Fixture / ModelTestCase |
| View of the current controller|`:Cview {view-name} ({theme-name})`  (`{theme-name}` is optional)| ||
| View of action the current controller|`:Cview`|  ||
| View of the specified controller|`:Ccontrollerview {controller-name} {view-name} ({theme-name})`  (`{theme-name}` is optional)||
| Config (core.php, database.php etc)|`:Cconfig {config-name}` | ok | |
| Component |`:Ccomponent {component-name}` | ok | ComponentTestCase |
| Behavior |`:Cbehavior {behavior-name}` | ok | BehaviorTestCase |
| Helper |`:Chelper {helper-name}` | ok | HelperTestCase |
| Shell |`:Cshell {shell-name}` | ok ||
| Task |`:Ctask {task-name}` | ok ||
| Cake Core library |`:Ccore {core-name}` | ok ||
| 1st party library |`:Clib {lib-name}` | ok ||
| Log File (like `tail -f`)|`:Clog {log-name}`  (See `g:cakephp_log`)|||
| Fixture |`:Cfixture {fixture-name}` | ok | Model|
| TestController |`:Ctestcontroller {controller-name}`| ok | Controller |
| TestModel |`:Ctestmodel {model-name}`| ok | Model |
| TestComponent |`:Ctestcomponent {component-name}`| ok | Component |
| TestBehavior |`:Ctestbehavior {behavior-name}`| ok | Behavior |
| TestHelper |`:Ctesthelper {helper-name}`| ok | Helper |
| Test (Any) |`:Ctest`|  | Controller / Model / Component / Behavior / Helper / Fixture |

## gf
- In Vim, you press the `gf` in normal mode, open the path it is written under the cursor, but, `gf` in a project in CakePHP to open the file of the object.
- `<C-w>f` is horizontal split, `<C-w>gf` is open in a tab, and `gs` is vertical split. See `g:cakephp_keybind_vsplit_gf`.

### Example

```php
// gf on AppController -> AppController
class MyController extends AppController {
  // gf with the following line -> layouts/2column.ctp
  var $layout = '2column';
  
  // gf on Post -> PostHelper
  var $helpers = array('Post');

  // gf on Session -> SessionComponent (CakePHP Core)
  var $components = array('Session');

  // gf with the following line -> index.ctp
  function index() {

    // gf with the following line -> layouts/default.ctp
    $this->layout = 'default';
    
    // gf on Post -> PostModel
    $this->Post->find('all')
    
    // gf on Set -> cake/libs/set.php
    Set::extract('/Post', $posts);
    
    // gf with the following line -> views/{controller-name}/pc/index.ctp
    $this->render('pc/index.ctp');
  }
}

// gf with the following line -> config
Configure::load('list');

// gf with the following line -> views/elements/pager.ctp
$this->element('pager');

// gf with the following line -> views/elements/sidebar/menu.ctp
$this->element('sidebar/menu');

// gf with the following line -> css/style.css
$html->css('style');

// gf with the following line -> js/jquery.js
$html->script('jquery');

// gf with the following line -> HogeController::fuga()
array('controller' => 'Hoge', 'action' => 'fuga')

// gf with the following line -> HogeController::admin_fuga()
array('controller' => 'Hoge', 'action' => 'fuga', 'admin' => true)

```

## Utility Command
- If [dbext.vim](http://www.vim.org/scripts/script.php?script_id=356) is installed, you can see the table definition of the model, `:Cdesc {model-name}`. If you do not specify an argument, the word under the cursor can be specified.
- `:Celement {element-name}` Cut out as an element the selected range. `:help :Celement`
- `:Cbake [{target}]` Run bake command interactively. `:help :Cbake`
- `:Ctestrun [{testmethod}]` Run test case command, guess depending on the type of the current buffer.
- `:Ctestrunmethod` Run the test method of the current line.

## unite-sources
- cake.vim is compatible with [unite.vim](https://github.com/Shougo/unite.vim).

| Target | Source |
| --- | --- |
|Controller|cake_controller|
|Model|cake_model
|View of the current controller|cake_view|
|View of the specified controller|cake_view:{controller-name}|
|Config|cake_config|
|Component|cake_component|
|Behavior|cake_behavior|
|Helper|cake_helper|
|Shell|cake_shell|
|Task|cake_task|
|Fixture|cake_fixture|
|Cake Core library |cake_core|
|1st party library |cake_lib|
