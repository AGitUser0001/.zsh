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
#endif

#exec <eval>

#for local i=0; i < 5; i++
echo repeats 5 times $i = 0, 1, 2, 3, 4
#break <-- this stops a loop
#continue <-- this goes to the next iteration
#done

#while true
echo infinite loop
#continue <-- skip
#break <-- stop
echo a
#done

#until true
echo never
#done
#until false
echo infloop
#done

#repeat 5
echo repeats 5 times
#done

#switch ${var:a}
  #case */*
  ls ${var:a}
  #if [[ $var == *\\* ]]
  #break
  #endif
  #continue
  #case *.*
  #case */*.*
  cat ${var:a}
  #break
  #case *
  echo ${var:a}
#done

#function hello
#if (( $1 ))
echo $1 world
#call-and-return hello $(( $1 - 2 ))
#elif (( $1 == 0 ))
echo $1 hello
#call-and-end hello $(( $1 - 5 ))
#else
#return 5
#endif
#end

#call hello

#label a
echo infinite loop
#goto a
echo will not print
```
The if and elif control whether the following code will be run depending on the status code.
The else inverts the stored status code in the if stack.
The endif pops the status code stack.
`#exec` runs a command.

For loops takes a `initializer; condition; incrementer`, and end with `#done`.
All three are optional, but there must be two semicolons, and the semicolons must be separated.
`#repeat <num>` repeats `<num>` times, as a shorthand for `#for`, but with the added advantage of not using a variable.
While loops take a `condition`, will run until the condition fails, and end with `#done`.
Until is the same as while, except the condition is negated.

The switch takes a string that will be expanded, the case takes a shell pattern, done exits switch.
Continue in switch cases will continue searching the cases, break in switch cases will exit the switch.

Functions take a name parameter and end with `#end`. If the function has no name, it is an iife and will be immediately invoked, in which case you can use `#end [args]`. Named functions can be called with `#call <name> [args]`. A function works by running a nested define. You can return values using `#return <value>`. `#call-and-return <name> [args]` calls a function and returns its result while in a function. Return will set $? outside of a function. Call-and-return will call a function normally outside of a function. `#call-and-end <name> [args]` will call a function and end the current function (return 0) in a function. Outside of a function, `#call-and-end` is invalid.

Labels take a name, which can have spaces but cannot be a positive integer.
`#goto <name>` goes to a named label.
`#goto <lineNo>` goes to a line.
Note that everything executes in order, so you cannot goto a label or call a function before it is defined.
You can also call functions by running `define:call <name> [args]`.
```zsh
#@1 if false
  echo will-not-print
echo will-print
#@if false
  echo same-result

#@2 if false
  echo will-not-print
  #exec echo will-not-print
  echo same
  #+exec echo will-not-print
#exec echo will-print
echo will-print

#if false
  echo a
  #@2
  echo b
  #@if false
    echo c
echo will-print
```
The @n applies the status for the next N lines. @ is a shorthand for @1.
When nested, the parent status line remaining count will decrement, but only pop once the child status pops.
You can apply @ to: if, elif, else, for, while, switch, function.

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
