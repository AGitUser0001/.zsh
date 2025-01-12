# ZSH Files

To install, clone this repository and run the install script.

```zsh
git clone git@github.com:AGitUser0001/.zsh.git;
.zsh/install;
```

## Folders

### cache
Caches for zsh, mainly .zcompcache and .zcompdump.

### history
Local ZSH history. Do not initialize submodule.

### config
Generated configuration by the installer script.

### define
See [definitions](#definition-files) below.

### crontab
Crontabs that will be asked to be installed by the installer script.

### functions
See [functions](#functions-1) below.

## Definition Files
Various definition files. The ./definitions file contain which files will be run in this format:

```zsh
$ZDOTDIR/define/filename <...prepend>
```

Each line of each definition file will be run like this:

```zsh
<...prepend> <...args> <line>
```

Unless the line is a comment (starts with a hash), in which case it will depend on the action:

```zsh
# comment
#args <...args>

#if <eval>
#elif <eval>
#else
#fi

#exec <eval>
```
The if and elif control whether the following code will be run depending on the status code.
The else inverts the stored status code in the if stack.
The fi pops the status code stack.
\<eval\> is a placeholder for code to be evaluated.

## Functions
Functions are under the ./functions folder.
This folder also contains several subfolders:

### functions/ln
This folder contains symbolic links and should not be modified manually. They are set up by the installation script.

### functions/zle
The contents of this folder are zle widgets. Each widget's filename should be formatted as `--widget-name`. The widget's actual name will be the filename without the `--`.

### functions/utils
This folder contains utility functions. The names of the functions should be preferably formatted as `__utility-name`.

### functions/hooks
These functions are either zle hooks or regular hooks. They should be formatted as `__hook-name`. `add-zsh-hook` or `add-zle-hook-widget` will be called respectively.

### functions/completion
The functions under this folder are completion functions, formatted as the standard `_completer-name`. They will be processed as normal by compinit.

### functions/wrappers
These functions are wrappers that can be linked to in other files in the functions folder. They should be relatively linked like `.path`.

### functions/math
Functions under this folder are math functions, and should be formatted as `zmath-funcname+options`. Options should be a comma seperated list of unique options, up to three:
  - `max=`*`n`*: The maximum number of arguments. n is an integer that is zero or greater.
  - `min=`*`n`*: The minimum number of arguments. n is an integer that is zero or greater.
  - `raw`: Whether the input should be a raw string. The min and max should be 1 if they are set.
