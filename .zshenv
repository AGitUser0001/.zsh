export ZDOTDIR="${${(%):-%x}:P:h}"
source $ZDOTDIR/config.zsh

SHELL_SESSIONS_DISABLE=1
typeset -x ZPATH PATH FPATH CDPATH MODULE_PATH
typeset -U zpath path fpath cdpath module_path ZPATH PATH FPATH CDPATH MODULE_PATH
typeset -T ZPATH zpath

SETUP='builtin emulate -LR zsh; builtin setopt extended_glob magic_equal_subst bsd_echo glob_star_short prompt_subst brace_ccl rematch_pcre combining_chars;'
builtin eval "${SETUP#*;}";
export PATH FPATH CDPATH MODULE_PATH
export CPPFLAGS='-I'$HOMEBREW_PREFIX'/opt/openjdk/include'

PS4='%F{red}+%e %N:%i %D{.%6.}> %f'
if (( ZSH_DEBUG )) zmodload zsh/zprof
[[ -r $ZDOTDIR/utils.zsh ]] && source $ZDOTDIR/utils.zsh

true # $? == 0
