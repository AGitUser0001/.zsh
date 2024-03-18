# ZSH modules
$ZDOTDIR/define/modules.zsh zmodload
# ZSH options
$ZDOTDIR/define/options.zsh setopt

# Named directories
$ZDOTDIR/define/directories.zsh hash -d

# Environment variables
$ZDOTDIR/define/environment.zsh export
# Shell variables
$ZDOTDIR/define/variables.zsh typeset -g

# Autoload functions
$ZDOTDIR/define/functions.zsh autoload

# Custom zsh hooks
$ZDOTDIR/define/hooks.zsh add-zsh-hook

# Source files
$ZDOTDIR/define/sources.zsh source

# ZLE widgets
$ZDOTDIR/define/widgets.zsh zle -N
# Key bindings
$ZDOTDIR/define/bindkey.zsh bindkey

# User aliases
$ZDOTDIR/define/aliases.zsh alias
