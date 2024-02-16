trim() {
  builtin enable emulate setopt read printf
  builtin emulate -LR zsh
  builtin setopt extended_glob
  
  local text="$*"
  if [[ $# -eq 0 ]] builtin read -rd '' text

  builtin printf %s ${${text%%[[:space:]]#}##[[:space:]]#}
}

clear() {
  builtin enable emulate setopt source
  builtin emulate -LR zsh
  builtin setopt extended_glob

  local reply=(clear E3)
  builtin source $ZDOTDIR/terminfo.zsh
}

erase() {
  builtin enable emulate setopt source
  builtin emulate -LR zsh
  builtin setopt extended_glob

  local reply=('cup 0 0' ed)
  builtin source $ZDOTDIR/terminfo.zsh
}

read-definition-file() {
  builtin enable print return shift read setopt eval
  case $# {
    (0) builtin print -u2 'Usage: read-definition-file <file> [<command>]'; builtin return 1;;
    (1) 2=$0;;
  }
  local flags= stack=() command= file=$1 REPLY= reply=
  builtin shift
  while builtin read -r command || [[ $command ]] {
    case $command {
      ('');;
      (\#*)
      local action="${command##\#}"
      if [[ -o extended_glob ]] {
        local data="${action##[^[:space:]]##[[:space:]]##}"
      } else {
        builtin setopt extended_glob
        local data="${action##[^[:space:]]##[[:space:]]##}"
        builtin setopt no_extended_glob
      }
      case $action {
        (flags[[:space:]]*) flags="$data";;
        (if[[:space:]]*) builtin eval "$data"; stack+=$?;;
        (elif[[:space:]]*) if (( stack[-1] )) { builtin eval "$data"; stack[-1]=$? } else { stack[-1]=0 } ;;
        (else) stack[-1]=$(( !stack[-1] ));; (fi) builtin shift -p stack;;
        (exec[[:space:]]*) if (( 0${(j"")stack} == 0 )) { builtin eval "$data" }; ;;
      };;
      (*) if (( 0${(j"")stack} == 0 )) { builtin eval "$@" $flags $command; }; ;;
    }
  } < $file
}
