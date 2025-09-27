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
  builtin enable emulate print return shift read unset eval
  local nested_define=0
  if [[ $1 == $'\0' ]] {
    nested_define=1
    builtin shift
  }
  case $# {
    (0) builtin print -u2 "Usage: $funcstack[1] <file> [<command>]"; builtin return 1;;
    (1) 2=$funcstack[1];;
  }
  local args env_status=0 line lineNo
  local -a stack stack_type stack_line stack_autopop lines
  local -a normal_options=( extended_glob on errexit off ) env_options


  if (( !nested_define )) {
    define:enter-env() {
      local return_status=$?
      options=( $env_options )
      if [[ $1 == --passthrough-status ]] {
        return $return_status
      } else {
        return $env_status
      }
    }
    define:exit-env() {
      local return_status=$?
      if [[ $1 != --ignore-status ]] {
        env_status=$return_status
      }
      env_options=( extended_glob $options[extended_glob] errexit $options[errexit] )
      options=( $normal_options )
      return $return_status
    }
    define:push-stack() {
      stack+=$1;
      stack_type+=$2;
      stack_line+=$lineNo;
      stack_autopop+=$temp_autopop;
    }
    define:pop-stack() {
      local -A corresponding_type=(
        for 1
        while 1
      )
      if [[ $corresponding_type[$stack_type[-1]] == 1 && $stack[-1] == 0 ]] {
        lineNo=$(( stack_line[-1] - 1 ))
        cont_loop=1
        return 1
      }
      builtin shift -p stack stack_type stack_line stack_autopop
    }
    define:clean-stack() {
      if (( allow_clean_stack )) {
        while (( stack_autopop[-1] < 0 )) {
          if { ! define:pop-stack; } {
            break
          }
        }
      }
    }
    define:get-statements() {
      define:exit-env
      local -a tokens=("${(z)data}")
      define:enter-env --ignore-status
      
      while (( ${#tokens} > 0 )) {
        local token_pos=${tokens[(i);]}
        if (( token_pos <= ${#tokens} )) {
          statements+=("${(j: :)tokens[1,$((token_pos-1))]}")
          tokens=("${(@)tokens[$((token_pos+1)),-1]}")
        } else {
          statements+=("${(j: :)tokens}")
          break
        }
      }
    }
  }

  define:exit-env;

  while { builtin read -r line || [[ $line ]] } {
    lines+=$line
  } < $1
  unset line
  builtin shift
  if [[ $1 == $funcstack[1] ]] {
    argv=($argv[1] $'\0' $argv[2,-1])
  }
  if [[ $1 == "--" ]] {
    shift
  }

  for (( lineNo = 1; lineNo <= $#lines + 1; lineNo++ )) {
    local temp_autopop=0 allow_clean_stack=1 command=$lines[$lineNo] cont_loop=0 statements=()
    if (( ZSH_DEBUG )) {
      print $lineNo$'\t'"${${:-0${(j"")stack}}:- }"$'\t'${stack_line[-1]}$'\t'${stack_type[-1]}$'\t'${(q)command}
    }

    if [[ $command == '#+'* ]] {
      command="#${command#\#+}"
      allow_clean_stack=0
    } 
    if (( allow_clean_stack )) {
      while (( $#stack && stack_autopop[-1] == -2 )) {
        if { ! define:pop-stack; } {
          break
        }
      }
    }
    if (( cont_loop )) { continue; }

    case $command {
      ([[:space:]]#);;
      (\#@(*~<->([[:space:]]*|)))
      command="#@1 ${command#\#@}";&
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
      (\#@(<->|));;
      (\#*)
      local action="${${command#\#}%%[[:space:]]*}"
      local data="${${command#\#}#*[[:space:]]}"
      case $action {
        ('');;
        (args) args="$data";;
        (if) define:enter-env; builtin eval "$data"; define:exit-env; define:push-stack $? if;;
        (for)
          define:get-statements;
          if (( $#statements != 3 )) {
            console:error for loop has $#statements statements
            define:push-stack 1 for
          }
          if (( stack_line[-1] != lineNo )) {
            define:enter-env; builtin eval "$statements[1]"; define:exit-env
            define:enter-env; builtin eval "(( $statements[2] ))"; define:exit-env
            define:push-stack $? for
          } else {
            define:enter-env; builtin eval "(( $statements[3] ))"; define:exit-env
            define:enter-env; builtin eval "(( $statements[2] ))"; define:exit-env
            stack[-1]=$?
          }; ;;
        (while)
          if (( stack_line[-1] != lineNo )) {
            define:enter-env; builtin eval "$data"; define:exit-env
            define:push-stack $? while
          } else {
            define:enter-env; builtin eval "$data"; define:exit-env
            stack[-1]=$?
          }; ;;
        (elif) stack_autopop[-1]=$temp_autopop;
               if (( stack[-1] )) {
                 define:enter-env; builtin eval "$data"; define:exit-env
                 stack[-1]=$?
               } else { stack[-1]=0 } ;;
        (else) stack[-1]=$(( !stack[-1] )); stack_autopop[-1]=$temp_autopop;;
        (done);&
        (fi)
          local -A corresponding_actions=(
            if fi
            for done
            while done
          )
          if [[ $corresponding_actions[$stack_type[-1]] == $action ]] {
            define:clean-stack; if (( cont_loop )) { continue; }
            define:pop-stack; if (( cont_loop )) { continue; } 
          } else {
            console:error invalid action in context: $action
          };;
        (exec) if (( 0${(j"")stack} == 0 )) {
          define:enter-env; builtin eval "$data"; define:exit-env
        }; ;;
        (*) console:error invalid action: $action;;;
      }; ;;
      (*)
      define:clean-stack;
      if (( cont_loop )) { continue; }
      if (( 0${(j"")stack} == 0 )) {
        define:enter-env
        builtin eval "${(q)@}" $args $command
        define:exit-env
      }
      local stack_autopop_index=
      for (( stack_autopop_index = 1; stack_autopop_index <= $#stack_autopop; stack_autopop_index++ )) {
        if (( stack_autopop[stack_autopop_index] > 0 )) {
          (( stack_autopop[stack_autopop_index]-- ))
          if (( stack_autopop[stack_autopop_index] == 0 )) {
            stack_autopop[$stack_autopop_index]=-2
          }
        }
      }; ;;
    }
  }
  true; define:enter-env --passthrough-status
  if (( !nested_define )) {
    unset -fm define:enter-env define:exit-env define:push-stack define:pop-stack define:clean-stack define:get-statements
  }
}

zle-push() {
  builtin emulate -L zsh
  if [[ ! -t 1 ]] return
  while { builtin read -rskt } { ZLE_PUSH+=$REPLY; }
}

console:error() {
  builtin emulate -L zsh
  builtin print -u2 $funcstack[-1]${*:+: $*};
}

console:log() {
  builtin emulate -L zsh
  builtin print -u1 $funcstack[-1]${*:+: $*};
}
