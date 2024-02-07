SAVEHIST=10000000 HISTSIZE=100000

SETUP='builtin emulate -LR zsh; builtin setopt extended_glob magic_equal_subst bsd_echo glob_star_short prompt_subst brace_ccl combining_chars c_bases octal_zeroes'

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
#fi

path=( ~/.bin/applets $zsh_path_override ~/.bin ~/.dotnet/tools $path )
path=( $path $HOMEBREW_PREFIX/opt/python/bin $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin )
path=( $path $HOMEBREW_PREFIX/opt/ruby/bin $HOMEBREW_PREFIX/opt/sqlite/bin $HOMEBREW_PREFIX/opt/curl/bin )
path=( $path /Library/Apple/usr/bin /usr/local/bin /usr/bin /bin /usr/sbin /sbin )
path=( $path /Library/Frameworks/Mono.framework/Versions/Current/Commands )

fpath=( $HOMEBREW_PREFIX/share/zsh/site-functions $HOMEBREW_PREFIX/share/zsh/functions $fpath )
fpath=( $HOMEBREW_PREFIX/opt/curl/share/zsh/site-functions $HOMEBREW_PREFIX/share/zsh-completions $fpath)
fpath=( $ZDOTDIR/functions $ZDOTDIR/functions/**(-/N) $fpath)

#if [[ $TERM_PROGRAM == Apple_Terminal ]]
BG="233";
#else
BG="none";
#fi

fpath[${fpath[(i)/usr/local/share/zsh/site-functions]}]=( )

module_path=( $module_path $HOMEBREW_PREFIX/lib/zsh )
