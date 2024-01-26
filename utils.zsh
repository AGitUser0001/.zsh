trim() {
  builtin emulate -LR zsh
  builtin setopt extended_glob
  
  builtin local text="$*"
  if [[ $# -eq 0 ]] builtin read -rd '' text

  builtin printf %s ${${text%%[[:space:]]#}##[[:space:]]#}
}

clear() {
  builtin emulate -LR zsh
  builtin setopt extended_glob

  if [[ $TERM == xterm(-*|) ]] {
    builtin printf '\e[H\e[2J\e[3J'
  } else {
    builtin printf '\e[H\e[2J'
  }
}

_log() {
  builtin emulate -LR zsh
  builtin zmodload zsh/parameter
  builtin local name=${functrace[1]:-$ZSH_ARGZERO};
  if [[ $1 == -n ]] { builtin shift; name=$1; }
  builtin print -u0 -- "$name:<log>:" $@
}

read-definition-file() {
  builtin emulate -LR zsh
  builtin setopt extended_glob
  case $# {
    (0) builtin print 'Usage: read-definition-file <file> [command]'; builtin return 0;;
    (1) 2=$0;;
  }
  builtin local flags= if=true file=$1
  builtin shift
  while builtin read -r || [[ $REPLY ]] {
    case $REPLY {
      (\#*) builtin local action=${REPLY##\#[[:space:]]#}
      case $action {
        (flags[[:space:]]##*) flags=${action##flags( |$'\t')##};|
        (if[[:space:]]##*) if=${action##if( |$'\t')##};|
      };;
      ('');;
      (*) builtin eval $if '&&' "$@" $flags $REPLY;;
    }
  } < $file >/dev/null
}

_err() {
  builtin emulate -LR zsh
  builtin zmodload zsh/parameter
  builtin local name=${functrace[1]:-$ZSH_ARGZERO}
  if [[ $1 == -n ]] { builtin shift; name=$1 }
  builtin print -u2 -- "$name:<err>:" $@
  builtin return 1
}

_evf() {
  [[ -r $1 ]] && builtin source $1
}
