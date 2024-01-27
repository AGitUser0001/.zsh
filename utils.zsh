trim() {
  builtin emulate -LR zsh
  builtin setopt extended_glob
  
  local text="$*"
  if [[ $# -eq 0 ]] builtin read -rd '' text

  builtin printf %s ${${text%%[[:space:]]#}##[[:space:]]#}
}

clear() {
  builtin emulate -LR zsh
  builtin zmodload zsh/terminfo
  builtin setopt extended_glob

  local reply=(clear E3)
  builtin source $ZDOTDIR/terminfo.zsh
}

_log() {
  builtin emulate -LR zsh
  builtin zmodload zsh/parameter
  local name=${functrace[1]:-$ZSH_ARGZERO};
  if [[ $1 == -n ]] { builtin shift; name=$1; }
  builtin print -u0 -- "$name:<log>:" $@
}

read-definition-file() {
  builtin emulate -LR zsh
  builtin setopt extended_glob
  case $# {
    (0) builtin print 'Usage: read-definition-file <file> [<command>]'; builtin return 0;;
    (1) 2=$0;;
  }
  local flags= if=true file=$1
  builtin shift
  while builtin read -r || [[ $REPLY ]] {
    case $REPLY {
      (\#*)
      local action="${REPLY##\#}"
      local data="${action##[^[:space:]]##[[:space:]]##}"
      case $action {
        (flags[[:space:]]##*) flags="$data";|
        (if[[:space:]]##*) if="$data";|
        (endif[[:space:]]#) if=true;|
      };;
      ('');;
      (*) if builtin eval "$if"; { builtin eval "$@" $flags $REPLY; };;
    }
  } < $file >/dev/null
}

_err() {
  builtin emulate -LR zsh
  builtin zmodload zsh/parameter
  local name=${functrace[1]:-$ZSH_ARGZERO}
  if [[ $1 == -n ]] { builtin shift; name=$1 }
  builtin print -u2 -- "$name:<err>:" $@
  builtin return 1
}

_evf() {
  [[ -r $1 ]] && builtin source $1
}
