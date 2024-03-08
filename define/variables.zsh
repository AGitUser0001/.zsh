SAVEHIST=10000000 HISTSIZE=100000

USER_ZDOTDIR=$ZDOTDIR

+x ZLE_PUSH="$ZLE_PUSH"
-U path fpath cdpath module_path PATH FPATH CDPATH MODULE_PATH

#if (( precmd_functions[(I)update_terminal_cwd] ))
precmd_functions[(I)update_terminal_cwd]=( )
chpwd_functions=( $chpwd_functions update_terminal_cwd )
#exec update_terminal_cwd
#fi

#exec /usr/libexec/path_helper -s | source /dev/stdin
path=( $zpath $path )

fpath=( $ZDOTDIR/functions $ZDOTDIR/functions/**(-/N) $HOMEBREW_PREFIX/opt/curl/share/zsh/site-functions $HOMEBREW_PREFIX/share/zsh-completions $HOMEBREW_PREFIX/share/zsh/site-functions $HOMEBREW_PREFIX/share/zsh/functions $fpath )

fpath[${fpath[(i)/usr/local/share/zsh/site-functions]}]=( )

module_path=( $module_path $HOMEBREW_PREFIX/lib/zsh )

-A ZSH_HIGHLIGHT_STYLES=( [function]=fg=#DCDCAA [command]=fg=#DCDCAA [builtin]=fg=#DCDCAA [precommand]=fg=#DCDCAA [comment]=fg=#6A9955 [unknown-token]=fg=#F44747 [reserved-word]=fg=#C586C0 [assign]=fg=#9CDCFE [default]=fg=#CE9178 [dollar-double-quoted-argument]=fg=#9CDCFE [single-quoted-argument]=fg=#CE9178 [double-quoted-argument]=fg=#CE9178 [dollar-quoted-argument]=fg=#CE9178 [back-double-quoted-argument]=fg=#D7BA7D [back-dollar-quoted-argument]=fg=#D7BA7D [rc-quote]=fg=#D7BA7D [command-substitution-delimiter]=fg=#CE9178 [process-substitution-delimiter]=fg=#CE9178 [arithmetic-expansion]=fg=#CE9178 [single-hyphen-option]=fg=#569CD6 [double-hyphen-option]=fg=#569CD6 [redirection]=fg=#FFFFFF [named-fd]=fg=#CE9178 [globbing]=fg=#569CD6 [path]=fg=#CE9178,underline )
