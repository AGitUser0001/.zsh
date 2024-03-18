# ZSH modules and options
$ZDOTDIR/define/modules.zsh zmodload
$ZDOTDIR/define/options.zsh setopt

# Named directories
$ZDOTDIR/define/directories.zsh hash -d

# Environment and shell variables
$ZDOTDIR/define/environment.zsh export
$ZDOTDIR/define/variables.zsh typeset -g

# Autoloaded functions
$ZDOTDIR/define/functions.zsh autoload

# Custom zsh hooks
$ZDOTDIR/define/hooks.zsh add-zsh-hook

# Source files
$ZDOTDIR/define/sources.zsh source

# ZLE widgets and key bindings
$ZDOTDIR/define/widgets.zsh zle -N
$ZDOTDIR/define/bindkey.zsh bindkey

# User aliases
$ZDOTDIR/define/aliases.zsh alias
