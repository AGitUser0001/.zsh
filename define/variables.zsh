SAVEHIST=10000000 HISTSIZE=100000

SETUP='builtin emulate -LR zsh; builtin setopt extended_glob magic_equal_subst bsd_echo glob_star_short prompt_subst brace_ccl combining_chars c_bases octal_zeroes'

USER_ZDOTDIR=$ZDOTDIR

+x ZLE_PUSH="$ZLE_PUSH"
-xT ZSH_PATH zsh_path
-U path fpath cdpath module_path PATH FPATH CDPATH MODULE_PATH

path[${path[(i)/bin]}]=( )
path[${path[(i)/sbin]}]=( )
path[${path[(i)/usr/bin]}]=( )
path[${path[(i)/usr/sbin]}]=( )
path[${path[(i)/usr/local/bin]}]=( )
path[${path[(i)/Library/Apple/usr/bin]}]=( )

path=( $zpath ~/.bin/applets ~/.bin ~/.dotnet/tools $path \
       $HOMEBREW_PREFIX/opt/python/bin $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin \
       $HOMEBREW_PREFIX/opt/ruby/bin $HOMEBREW_PREFIX/opt/sqlite/bin $HOMEBREW_PREFIX/opt/curl/bin \
       /Library/Apple/usr/bin /usr/local/bin /usr/bin /bin /usr/sbin /sbin \
       /Library/Frameworks/Mono.framework/Versions/Current/Commands )

fpath=( $ZDOTDIR/functions $ZDOTDIR/functions/**(-/N) \
        $HOMEBREW_PREFIX/opt/curl/share/zsh/site-functions $HOMEBREW_PREFIX/share/zsh-completions \
        $HOMEBREW_PREFIX/share/zsh/site-functions $HOMEBREW_PREFIX/share/zsh/functions $fpath )

#if [[ $TERM_PROGRAM == Apple_Terminal ]]
BG="233";
#else
BG="none";
#fi

fpath[${fpath[(i)/usr/local/share/zsh/site-functions]}]=( )

module_path=( $module_path $HOMEBREW_PREFIX/lib/zsh )
