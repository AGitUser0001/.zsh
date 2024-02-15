trim() {
  builtin emulate -LR zsh
  builtin setopt extended_glob
  
  local text="$*"
  if [[ $# -eq 0 ]] builtin read -rd '' text

  builtin printf %s ${${text%%[[:space:]]#}##[[:space:]]#}
}

clear() {
  builtin emulate -LR zsh
  builtin setopt extended_glob

  local reply=(clear E3)
  builtin source $ZDOTDIR/terminfo.zsh
}

erase() {
  builtin emulate -LR zsh
  builtin setopt extended_glob

  local reply=('cup 0 0' ed)
  builtin source $ZDOTDIR/terminfo.zsh
}

read-definition-file() {
  case $# {
    (0) builtin print 'Usage: read-definition-file <file> [<command>]'; builtin return 0;;
    (1) 2=$0;;
  }
  local flags= stack=() command= file=$1 REPLY= reply=
  builtin shift
  while builtin read command || [[ $command ]] {
    case $command {
      (\#*)
      local action="${command##\#}"
      if [[ -o extended_glob ]] {
        local data="${action##[^[:space:]]##[[:space:]]##}"
      } else {
        setopt extended_glob
        local data="${action##[^[:space:]]##[[:space:]]##}"
        unsetopt extended_glob
      }
      case $action {
        (flags[[:space:]]*) flags="$data";;
        (if[[:space:]]*) builtin eval "$data"; stack+=$((!?));;
        (elif[[:space:]]*) if (( stack[-1] )) { builtin eval "$data"; stack[-1]=$((!?)) } else { stack[-1]=0 } ;;
        (else) stack[-1]=$(( !stack[-1] ));; (fi) shift -p stack;;
        (exec[[:space:]]*) if (( $#stack == 0 || stack[-1] )) { builtin eval "$data" }; ;;
      };;
      ('');;
      (*) if (( $#stack == 0 || stack[-1] )) { builtin eval "$@" $flags $command; }; ;;
    }
  } < $file
}

_evf() {
  [[ -r $1 ]] && builtin source $1
}
