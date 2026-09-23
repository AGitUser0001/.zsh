export ZDOTDIR="${${(%):-%x}:P:h}"
source $ZDOTDIR/config/zshenv

SHELL_SESSIONS_DISABLE=1
typeset -x ZPATH PATH FPATH CDPATH MODULE_PATH
typeset -U zpath path fpath cdpath module_path ZPATH PATH FPATH CDPATH MODULE_PATH
typeset -T ZPATH zpath

SETUP_OPTIONS=(extended_glob magic_equal_subst bsd_echo glob_star_short prompt_subst brace_ccl rematch_pcre)
SETUP='builtin emulate -L zsh; builtin setopt $SETUP_OPTIONS;'
builtin eval "${SETUP#*;}";
export PATH FPATH CDPATH MODULE_PATH
if [[ $OSTYPE == linux* ]]; then
  path=( $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin $path )
  [[ -d $HOMEBREW_PREFIX/opt/python/libexec/bin ]] && path=( $HOMEBREW_PREFIX/opt/python/libexec/bin $path )
fi
if [[ $OSTYPE == darwin* ]]; then
  _jdk_home=$HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home
else
  _jdk_home=$HOMEBREW_PREFIX/opt/openjdk
fi
if [[ -d $_jdk_home ]]; then
  export JAVA_HOME=$_jdk_home
  [[ -d $JAVA_HOME/include ]] && export CPPFLAGS="${CPPFLAGS:+$CPPFLAGS }-I$JAVA_HOME/include"
fi
unset _jdk_home
[[ -d $HOMEBREW_PREFIX/opt/llvm/lib ]] && export LDFLAGS="${LDFLAGS:+$LDFLAGS }-L$HOMEBREW_PREFIX/opt/llvm/lib"
[[ -d $HOMEBREW_PREFIX/opt/llvm/include ]] && export CPPFLAGS="${CPPFLAGS:+$CPPFLAGS }-I$HOMEBREW_PREFIX/opt/llvm/include"

PS4='%F{red}+%e %N:%i %D{.%6.}> %f'
if (( ZSH_DEBUG )) zmodload zsh/zprof
[[ -r $ZDOTDIR/utils.zsh ]] && source $ZDOTDIR/utils.zsh

true # $? == 0
