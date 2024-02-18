SAVEHIST=10000000 HISTSIZE=100000

SETUP='builtin emulate -LR zsh; builtin setopt extended_glob magic_equal_subst bsd_echo glob_star_short prompt_subst brace_ccl combining_chars'

USER_ZDOTDIR=$ZDOTDIR

+x ZLE_PUSH="$ZLE_PUSH"
-xT ZSH_PATH zsh_path
-U path fpath cdpath module_path PATH FPATH CDPATH MODULE_PATH

#if (( precmd_functions[(I)update_terminal_cwd] ))
precmd_functions[(I)update_terminal_cwd]=( )
chpwd_functions=( $chpwd_functions update_terminal_cwd )
#fi

#exec /usr/libexec/path_helper -s | source /dev/stdin
path=( $zpath $path )

fpath=( $ZDOTDIR/functions $ZDOTDIR/functions/**(-/N) $HOMEBREW_PREFIX/opt/curl/share/zsh/site-functions $HOMEBREW_PREFIX/share/zsh-completions $HOMEBREW_PREFIX/share/zsh/site-functions $HOMEBREW_PREFIX/share/zsh/functions $fpath )

# #if [[ -t 1 ]]
# #if [[ $TERM_PROGRAM == "vscode" ]]
# #exec printf '\e]11;?\a'; read -rsd $'\\' < /dev/tty;
# BG=$REPLY$'\\'
# #else
# #exec printf '\e]11;?\a'; read -rsd $'\a' < /dev/tty;
# BG=$REPLY$'\a'
# #fi
# #fi

fpath[${fpath[(i)/usr/local/share/zsh/site-functions]}]=( )

module_path=( $module_path $HOMEBREW_PREFIX/lib/zsh )
