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
| View of the specified controller|`:CControllerview {controller-name} {view-name} ({theme-name})`  (`{theme-name}` is optional)||
| Config (core.php, database.php etc)|`:Cconfig {config-name}` | ok | |
| Component |`:Ccomponent {component-name}` | ok | ComponentTestCase |
| Behavior |`:Cbehavior {behavior-name}` | ok | BehaviorTestCase |
| Helper |`:Chelper {helper-name}` | ok | HelperTestCase |
| Shell |`:Cshell {shell-name}` | ok ||
| Task |`:Ctask {task-name}` | ok ||
| Cake Core |`:CLib {lib-name}` | ok ||
| Log File (like `tail -f`)|`:Clog {log-name}`  (See `g:cakephp_log`)|||
| TestController |`:Ctestcontroller {controller-name}`| ok | Controller |
| TestModel |`:Ctestmodel {model-name}`| ok | Model |
| TestComponent |`:Ctestcomponent {component-name}`| ok | Component |
| TestBehavior |`:Ctestbehavior {behavior-name}`| ok | Behavior |
| TestHelper |`:Ctesthelper {helper-name}`| ok | Helper |
| Test (Any) |`:Ctest`|  | Controller / Model / Component / Behavior / Helper / Fixture |





[Vundle]:http://github.com/gmarik/vundle
