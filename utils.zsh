trim() {
  builtin enable emulate setopt read printf
  builtin emulate -L zsh
  builtin setopt extended_glob
  
  local text="$*"
  if [[ $# -eq 0 ]] builtin read -rd '' text

  builtin printf %s ${${text%%[[:space:]]#}##[[:space:]]#}
}

clear() {
  builtin enable emulate setopt source
  builtin emulate -L zsh
  builtin setopt extended_glob

  local reply=(clear E3)
  builtin source $ZDOTDIR/terminfo.zsh
}

erase() {
  builtin enable emulate setopt source
  builtin emulate -L zsh
  builtin setopt extended_glob

  local reply=('cup 0 0' ed)
  builtin source $ZDOTDIR/terminfo.zsh
}

define() {
  builtin enable print return shift read setopt eval
  case $# {
    (0) builtin print -u2 "Usage: $funcstack[1] <file> [<command>]"; builtin return 1;;
    (1) 2=$funcstack[1];;
  }
  local args stack=() stack_autopop=()  command file=$1
  builtin shift
  while builtin read -r command || [[ $command ]] {
    local temp_autopop=0

    case $command {
      ('');;
      (\#@<->([[:space:]]*|))
      temp_autopop="${${command#\#@}%%[[:space:]]*}"
      if (( !temp_autopop )) {
        temp_autopop=-1
      }
      command="#${command#\#@*[[:space:]]}"
      if [[ "$command" == "" ]] {
        if (( $#stack_autopop && temp_autopop )) {
          stack_autopop[-1]=$temp_autopop
        }
      }; ;|
      (\#@<->);;
      (\#*)
      local action="${${command#\#}%%[[:space:]]*}"
      local data="${${command#\#}#*[[:space:]]}"
      case $action {
        ('');;
        (args) args="$data";;
        (if) builtin eval "$data"; stack+=$?; stack_autopop+=$temp_autopop;;
        (elif) stack_autopop[-1]=$temp_autopop;
               if (( stack[-1] )) { builtin eval "$data"; stack[-1]=$? } else { stack[-1]=0 } ;;
        (else) stack[-1]=$(( !stack[-1] )); stack_autopop[-1]=$temp_autopop;; (fi) builtin shift -p stack stack_autopop;;
        (exec) if (( 0${(j"")stack} == 0 )) { builtin eval "$data"; }; ;;
        (*) console:error invalid action: $action;;;
      }; ;;
      (*)
      if (( stack_autopop[-1] < 0 )) {
        builtin shift -p stack stack_autopop
      }
      if (( 0${(j"")stack} == 0 )) { builtin eval "${(q)@}" $args $command; };
      if (( stack_autopop[-1] > 0 )) {
        (( stack_autopop[-1]-- ))
        if (( stack_autopop[-1] == 0 )) {
          builtin shift -p stack stack_autopop
        }
      }
      ;;
    }
  } < $file
}

zle-push() {
  builtin emulate -L zsh
  if [[ ! -t 1 ]] return
  while { builtin read -rskt } { ZLE_PUSH+=$REPLY; }
}

console:error() {
  builtin emulate -L zsh
  builtin print -u2 $funcstack[-1]${1:+: $1};
}

console:log() {
  builtin emulate -L zsh
  builtin print -u1 $funcstack[-1]${1:+: $1};
}
