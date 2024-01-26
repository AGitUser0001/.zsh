PROMPT4='%F{red}+%e %N:%i %D{.%6.}> %f'
[[ -r $ZDOTDIR/utils.zsh ]] && source $ZDOTDIR/utils.zsh

SHELL_SESSIONS_DISABLE=1
typeset -U path fpath cdpath module_path PATH FPATH CDPATH MODULE_PATH

setopt extended_glob magic_equal_subst bsd_echo glob_star_short prompt_subst brace_ccl
export PATH

read-definition-file $ZDOTDIR/define/nameddirs.zsh hash -d

true # $? == 0
