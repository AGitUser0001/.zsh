export ZDOTDIR="${${(%):-%x}:P:h}"
source $ZDOTDIR/config/zshenv

SHELL_SESSIONS_DISABLE=1
typeset -x ZPATH PATH FPATH CDPATH MODULE_PATH
typeset -U zpath path fpath cdpath module_path ZPATH PATH FPATH CDPATH MODULE_PATH
typeset -T ZPATH zpath

SETUP='builtin emulate -L zsh; builtin setopt extended_glob magic_equal_subst bsd_echo glob_star_short prompt_subst brace_ccl rematch_pcre;'
builtin eval "${SETUP#*;}";
export PATH FPATH CDPATH MODULE_PATH
export CPPFLAGS='-I'$HOMEBREW_PREFIX'/opt/openjdk/include'
export JAVA_HOME=$HOMEBREW_PREFIX'/opt/openjdk/libexec/openjdk.jdk/Contents/Home'

PS4='%F{red}+%e %N:%i %D{.%6.}> %f'
if (( ZSH_DEBUG )) zmodload zsh/zprof
[[ -r $ZDOTDIR/utils.zsh ]] && source $ZDOTDIR/utils.zsh

true # $? == 0
