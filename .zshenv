export ZDOTDIR="${${(%):-%x}:P:h}"
PS4='%F{red}+%e %N:%i %D{.%6.}> %f'
if (( ZSH_DEBUG )) zmodload zsh/zprof
[[ -r $ZDOTDIR/utils.zsh ]] && source $ZDOTDIR/utils.zsh

SHELL_SESSIONS_DISABLE=1
typeset +x ZSH_IGNORE_LOGIN
typeset -U path fpath cdpath module_path PATH FPATH CDPATH MODULE_PATH

setopt extended_glob magic_equal_subst bsd_echo glob_star_short prompt_subst brace_ccl
export PATH FPATH CDPATH MODULE_PATH
export CPPFLAGS='-I/opt/homebrew/opt/openjdk/include'

read-definition-file $ZDOTDIR/define/nameddirs.zsh hash -d

true # $? == 0
