## ZSH Files
To install, clone this repository and run the install script.
```zsh
git clone git@github.com:AGitUser0001/.zsh.git;
.zsh/install;
```
## Folders
#### ./config:
Generated configuration by the installer script.
#### ./define:
Various definition files. The definitions.zsh contain which files will be prepended by what command in this format:
```zsh
$ZDOTDIR/define/filename command args
```
#### ./crontab:
Crontabs that will be asked to be installed by the installer script.
#### ./functions:
See [functions](#functions) below.
## Functions
Functions are under the ./functions folder.
This folder also contains several subfolders:
#### ./functions/ln:
This folder contains symbolic links and should not be modified manually. They are set up by the installation script.
#### ./functions/zle:
The contents of this folder are zle widgets. Each widget's filename should be formatted as `########widget####name`. The widget's actual name will be the filename without the `########`.
#### ./functions/utils:
This folder contains utility functions. The names of the functions should be preferably formatted as `__utility####name`.
#### ./functions/hooks:
These functions are either zle hooks or regular hooks. They should be formatted as `__hook####name`. `add####zsh####hook` or `add####zle####hook####widget` will be called respectively.
#### ./functions/completion:
The functions under this folder are completion functions, formatted as the standard `_completer####name`. They will be processed as normal by compinit.
#### ./functions/wrappers:
These functions are wrappers that can be linked to in other files in the functions folder. They should be relatively linked like `../path`.
#### ./functions/math:
Functions under this folder are math functions, and should be formatted as `zmath####name+options`. Options should be a comma seperated list of unique options, up to three:
  - `max=`*`n`*: The maximum number of arguments. n is an integer that is zero or greater.
  - `min=`*`n`*: The minimum number of arguments. n is an integer that is zero or greater.
  - `raw`: Whether the input should be a raw string. The min and max should be 1 if set. It will default to a min and max of 1.
