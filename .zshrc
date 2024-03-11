read-definition-file $ZDOTDIR/define/definitions.zsh
__reset-tty
__reset

zle-push

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

LASTCMDSTART=-1
elapsed=( )

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

PS1=$'%K{blue} %3~ %F{blue}%(4V"%K{%1v}%F{%2v} %B%3v%4v%5v%b %F{%1v}")%K{%6v}%F{%7v} %8vs %-50(l"%F{%6v}%K{black}%F{white} "\n%k%f)%(#"%B%F{red}")%# %b%f%k'
PS2=$'%K{208}%F{black} $(
  builtin eval "$SETUP"
  printf %s ${${(j"  ")${${=${(%):-%_}}}}[1,-12]}
) %k%f%b%s %(#"%B%F{red}%#%b%f"%#) '
PS3=$'%K{green}%F{black} ? %k%f%b%s '
PS4='%K{red}%F{white} %e %N:%i %D{.%6.} %k%f%b%s '
RPS1=$'%(9V.%(?..%K{red}%f %? ).)'
SPROMPT="%K{8} '%R' to '%r'  [n]o  yes  abort  edit %k%f%b%s "

__reset

zle-push
true # $? == 0
