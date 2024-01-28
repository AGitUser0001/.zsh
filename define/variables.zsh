SAVEHIST=10000000 HISTSIZE=100000

_default_setup='builtin emulate -LR zsh; builtin setopt extended_glob magic_equal_subst bsd_echo glob_star_short prompt_subst brace_ccl combining_chars c_bases octal_zeroes'

USER_ZDOTDIR=$ZDOTDIR

+x ZLE_PUSH="$ZLE_PUSH"
-xT ZSH_PATH_OVERRIDE zsh_path_override
-U path fpath cdpath module_path PATH FPATH CDPATH MODULE_PATH

#if [[ -o login && $ZSH_IGNORE_LOGIN != 1 ]]
path[${path[(i)/bin]}]=( )
path[${path[(i)/sbin]}]=( )
path[${path[(i)/usr/bin]}]=( )
path[${path[(i)/usr/sbin]}]=( )
path[${path[(i)/usr/local/bin]}]=( )
path[${path[(i)/Library/Apple/usr/bin]}]=( )
#endif

path=( ~/.bin/applets $zsh_path_override ~/.bin ~/.dotnet/tools $path )
path=( $path /opt/homebrew/opt/python/bin /opt/homebrew/bin /opt/homebrew/sbin )
path=( $path /opt/homebrew/opt/ruby/bin /opt/homebrew/opt/sqlite/bin /opt/homebrew/opt/curl/bin )
path=( $path /Library/Apple/usr/bin /usr/local/bin /usr/bin /bin /usr/sbin /sbin )
path=( $path /Library/Frameworks/Mono.framework/Versions/Current/Commands )

fpath=( /opt/homebrew/share/zsh/site-functions /opt/homebrew/share/zsh/functions $fpath )
fpath=( /opt/homebrew/opt/curl/share/zsh/site-functions /opt/homebrew/share/zsh-completions $fpath)
fpath=( $ZDOTDIR/functions $ZDOTDIR/functions/**(-/N) $fpath)

BG="%k"
#if [[ $TERM_PROGRAM == Apple_Terminal ]]
BG="%K{233}"
#endif

fpath[${fpath[(i)/usr/local/share/zsh/site-functions]}]=( )

module_path=( $module_path /opt/homebrew/lib/zsh )
