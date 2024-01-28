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
PS1=$'%K{blue} %3~ %F{blue}%(5V"%K{%2v}%F{%3v} %B%4v%5v%6v%b %F{%2v}")%K{%7v}%F{%8v} %9vs %K{%1v}%F{%7v}%k%f%b%s %(#"%B%F{red}%#%b%f"%#) '
PS2=$'%K{208}%F{black} $(
  eval $_default_setup
  printf %s ${${(j"  ")${${=${(%):-%_}}}}[1,-12]}
) %K{%1v}%F{208}%k%f%b%s %(#"%B%F{red}%#%b%f"%#) '
PS3=$'%K{green}%F{black} ? %K{%1v}%F{green}%k%f%b%s '
PS4='%K{red}%F{white} +%e %N:%i %D{.%6.}%K{%1v}%F{red}%k%f%b%s '
RPS1=$'%(10V.%(?..%K{%1v}%F{red}%K{red}%f %? ).)'
SPROMPT="%K{8} '%R' to '%r'  [n]o  [y]es  [a]bort  [e]dit %K{%1v}%F{8}%k%f%b%s "

__reset

while { read -rskt } { ZLE_PUSH+=$REPLY }
true # $? == 0
