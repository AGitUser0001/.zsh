read-definition-file $ZDOTDIR/define/definitions.zsh read-definition-file

if [[ ${:P} != $PWD ]] cd ${:P};
while { read -rskt } { ZLE_PUSH+=$REPLY }

() {
  local fn
  for fn ( ${functions[(I)zmath-?*]} ) {
    local x=${fn##*+} opts=( ) args=( ${${fn%+*}#zmath-} 1 -1 )
    local -a match mbegin mend

    case $x {
      (zmath-*);;
      ((*,|)raw(,*|)) opts+=( -s ) && args[2,3]=( 1 1 );|
      ((#b)(*,|)name=([^,]##)(,*|)) args[1]=$match[2];|
      ((#b)(*,|)min=([0-9]##)(,*|)) args[2]=$match[2];|
      ((#b)(*,|)max=([0-9]##)(,*|)) args[3]=$match[2];|
    }
    functions -M $opts -- $args $fn
  }
}

__lasttimestart=-1
_elapsed=( )

add-zsh-hook chpwd chpwd_recent_dirs
add-zsh-hook -Uz zsh_directory_name zsh_directory_name_cdr
() {
  local i
  for i ( $functions[(I)__?*] ) {
    if [[ $functions_source[$i] == $fpath[1]/hooks/(*/)#__?* ]] case ${${${i#__}%%+*}%%\=*} {
      (chpwd|precmd|preexec|periodic) ;&
      (zshaddhistory|zshexit|zsh_directory_name) add-zsh-hook ${${${i#__}%%+*}%%\=*} $i;;
      (isearch-exit|isearch-update|line-pre-redraw|line-init) ;&
      (line-finish|history-line-set|keymap-select) 
        zle -N zle-func-${${i#__}%%+*} $i
        add-zle-hook-widget ${${${i#__}%%+*}%%\=*} zle-func-${${i#__}%%+*};;
      (*) return 1;
    }
  }
}

__reset
CURRENT_GIT_BRANCH=''
TITLE=''
TAB_TITLE=''
WORDCHARS='*?'
HELP_SKIPFUNC=( visudo purge )

PROMPT_EOL_MARK='%k%f%b%s'
PROMPT=$'%K{blue} %3~ %F{blue}%(4V"%K{%1v}%F{%2v} %B%3v%4v%5v%b %F{%1v}")%K{%6v}%F{%7v} %8vs $__nobg%F{%6v} %k%f%b%s%(#"%B%F{red}%#%b%f"%#) '
PROMPT2=$'%K{208}%F{black} $(
  eval $_default_setup
  printf %s ${${(j"  ")${${=${(%):-%_}}}}[1,-12]}
) $__nobg%F{208} %k%f%b%s'
RPROMPT=$'%(9V.%(?..$__nobg%F{red}%K{red}%f %? ).)'

__reset

while { read -rskt } { ZLE_PUSH+=$REPLY }
true # $? == 0
