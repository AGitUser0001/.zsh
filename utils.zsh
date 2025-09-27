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
  local nested_define=0 function_mode=0
  local -a function_args=( )
  if [[ $1 == $'\0function' ]] {
    function_mode=1
    function_args=( "${(@)function_params}" )
  }
  if [[ $1 == $'\0'* ]] {
    nested_define=1
    builtin shift
  }
  local -a true_argv=( "$@" )
  case $# {
    (0) builtin print -u2 "Usage: $funcstack[1] <file> [<command>]"; builtin return 1;;
    (1) 2=$funcstack[1];;
  }
  local prepend_args env_status=0 env_subcontext=0 define_exit_status=0 line lineNo
  local -a stack stack_type stack_line stack_autopop lines prepend_command
  local -a normal_options=( extended_glob on errexit off ) env_options
  local -A frame_data functions_start functions_end labels
  local in_function=0 in_iife=0 in_function_name=

  if (( !nested_define )) {
    define:enter-env() {
      local return_status=$?
      options=( $env_options )
      if [[ $1 != --not-subcontext ]] {
        options[errexit]=off
        env_subcontext=0
      }
      if [[ $1 == --passthrough-status ]] {
        builtin return $return_status
      } else {
        builtin return $env_status
      }
    }
    define:exit-env() {
      local return_status=$?
      if [[ $1 != --ignore-status ]] {
        env_status=$return_status
      }
      if (( env_subcontext )) {
        options[errexit]=$env_options[4]
      }
      env_options=( extended_glob $options[extended_glob] errexit $options[errexit] )
      options=( $normal_options )
      env_subcontext=1
      builtin return $return_status
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
        builtin return 1
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
      define:enter-env
      local -a tokens=("${(z)data}")
      define:exit-env --ignore-status
      
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
    define:error() {
      builtin print -u2 $funcstack[-1]${*:+: $*};
      define:enter-env --not-subcontext
      define:return-status 1
      define:exit-env --ignore-status
    }
    define:call() {
      local start_lineNo=$functions_start[$1] end_lineNo=$functions_end[$1]
      if [[ -z $start_lineNo ]] {
        define:error start of function not found: "${(q)1}"
        builtin return 1
      } elif [[ -z $end_lineNo ]] {
        define:error end of function not found: "${(q)1}"
        builtin return 1
      }
      builtin shift
      local -a function_params=( "$@" )
      if (( env_subcontext == 0 )) {
        define:enter-env --not-subcontext;
      } else {
        define:enter-env
      }
      define $'\0function' "${(@)true_argv}" <<< "${(pj:\n:)lines[$start_lineNo + 1,$end_lineNo - 1]}"
      define:exit-env;
    }
    define:return-status() {
      builtin return $1
    }
  }

  define:exit-env;

  while { builtin read -r line || [[ $line ]] } {
    lines+=$line
  } < $1
  builtin unset line
  builtin shift
  if [[ $1 == $funcstack[1] ]] {
    argv=($argv[1] $'\0' $argv[2,-1])
  }
  if [[ $1 == "--" ]] {
    builtin shift
  }

  prepend_command=( "$@" )
  argv=( "${(@)function_args}" )

  for (( lineNo = 1; lineNo <= $#lines + 1; lineNo++ )) {
    local temp_autopop=0 allow_clean_stack=1 command=$lines[$lineNo] cont_loop=0 statements=()
    if (( ZSH_DEBUG )) {
      builtin print $lineNo$'\t'"${${:-0${(j"")stack}}:- }"$'\t'${stack_line[-1]}$'\t'${stack_type[-1]}$'\t'${(@q)command}
    }

    if (( in_function )) {
      if [[ $command == \#(@(<->[[:space:]]|)|)(+|)end([[:space:]]*|) ]] {
        functions_end[$stack_line[-1]]=$lineNo
        define:pop-stack
        in_function=0
        if (( in_iife )) {
          builtin eval 'define:call "$in_function_name"' ${command##\#(@(<->[[:space:]]|)|)(+|)end([[:space:]]|)}
        }
        in_iife=0 in_function_name=
      }
      continue
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
      local trimmed_data="${${data##[[:space:]]#}%%[[:space:]]#}"
      case $action {
        ('');;
        (args) prepend_args="$data";;
        (if) define:enter-env; builtin eval "$data"; define:exit-env; define:push-stack $? if;;
        (for)
          define:get-statements;
          if (( $#statements != 3 )) {
            define:error for loop has $#statements statements
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
        (switch)
        define:push-stack 0 switch;
        define:enter-env;
        frame_data[$lineNo]="${(e)trimmed_data}"
        define:exit-env --ignore-status;;
        (case)
        define:clean-stack; if (( cont_loop )) { continue; }
        if [[ $stack_type[-1] == case ]] {
          local prev_case_status=$stack[-1]
          define:pop-stack; if (( cont_loop )) { continue; } 
          define:push-stack $prev_case_status case;
        } elif [[ $stack_type[-1] == switch ]] {
          if [[ $stack[-1] == 0 ]] {
            local switch_data=$frame_data[$stack_line[-1]]
            define:enter-env
            [[ "$switch_data" == ${~trimmed_data} ]]
            define:exit-env --ignore-status
            define:push-stack $? case;
          } else {
            define:push-stack 1 case;
          }
        } else {
          define:error invalid action in context: $action
        };;
        (elif) stack_autopop[-1]=$temp_autopop;
               if (( stack[-1] )) {
                 define:enter-env; builtin eval "$data"; define:exit-env
                 stack[-1]=$?
               } else { stack[-1]=0 } ;;
        (else) stack[-1]=$(( !stack[-1] )); stack_autopop[-1]=$temp_autopop;;
        (break)
          define:clean-stack; if (( cont_loop )) { continue; }
          if [[ $stack_type[-1] == case ]] {
            define:pop-stack; if (( cont_loop )) { continue; } 
            if [[ $stack_type[-1] == switch ]] {
              stack[-1]=1
            }
          } else {
            define:error invalid action in context: $action
          };;
        (return)
          if (( function_mode )) {
            define_exit_status=$data
            break
          } else {
            define:enter-env --not-subcontext
            define:return-status $data
            define:exit-env
          };;
        (call)
          builtin eval 'define:call "$in_function_name"' $data;;
        (label) if [[ $trimmed_data == <-> || -z $trimmed_data ]] {
                  define:error invalid label: "${(q)trimmed_data}"
                } else {
                  labels[$trimmed_data]=$lineNo
                };;
        (goto) if (( 0${(j"")stack} == 0 )) {
                 if [[ $trimmed_data == <-> ]] {
                   lineNo=$(( trimmed_data - 1 ))
                   continue
                 } else {
                   if [[ -n $labels[$trimmed_data] ]] {
                     lineNo=$(( labels[$trimmed_data] - 1 ))
                     continue
                   } else {
                     define:error invalid label: "${(q)trimmed_data}"
                     local labels
                   }
                 }
               }; ;;
        (function) if [[ -z trimmed_data ]] {
                     in_iife=1
                   }
                   functions_start[$trimmed_data]=$lineNo
                   in_function=1
                   in_function_name=$trimmed_data
                   define:push-stack 0 function;;
        (end) define:error invalid action in context: $action;;
        (continue);&
        (done);&
        (fi)
          define:clean-stack; if (( cont_loop )) { continue; }
          local -A corresponding_actions=(
            if fi
            for done
            while done
            switch done
            case continue
          )
          if [[ $stack_type[-1] == case && $stack_type[-2] == switch && $action == done ]] {
            define:pop-stack; if (( cont_loop )) { continue; }
            define:pop-stack; if (( cont_loop )) { continue; }
          } elif [[ $corresponding_actions[$stack_type[-1]] == $action ]] {
            define:pop-stack; if (( cont_loop )) { continue; }
          } else {
            define:error invalid action in context: $action
          };;
        (exec) if (( 0${(j"")stack} == 0 )) {
          define:enter-env --not-subcontext; builtin eval "$data"; define:exit-env
        }; ;;
        (*) define:error invalid action: $action;;
      }; ;;
      (*)
      define:clean-stack;
      if (( cont_loop )) { continue; }
      if (( 0${(j"")stack} == 0 )) {
        define:enter-env --not-subcontext
        builtin eval "${(@q)prepend_command}" $prepend_args $command
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
  define:return-status 0
  define:enter-env --not-subcontext --passthrough-status
  if (( !nested_define )) {
    builtin unset -fm 'define:*' || true
  }
  builtin return $define_exit_status
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
