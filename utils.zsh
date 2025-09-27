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
  local nested_define=0 function_mode=0 function_name= name_of_self=$funcstack[1]
  local -a function_args=( )
  if [[ $1 == $'\0function' ]] {
    function_mode=1
    function_args=( "${(@)function_params}" )
    function_name=$2
  }
  if [[ $1 == $'\0'* ]] {
    nested_define=1
    builtin shift
  }
  case $# {
    (0) builtin print -u2 "Usage: $name_of_self <file> [<command>]"; builtin return 1;;
    (1) 2=$name_of_self;;
  }
  local prepend_args env_status=0 in_env=1 define_exit_status=0 line lineNo
  local -a stack stack_type stack_line stack_autopop prepend_command env_subcontext
  local -a normal_options=( extended_glob on errexit off ) env_options
  local -A frame_data
  local in_function=0 in_iife=0 in_function_name=

  if (( !nested_define )) {
    define:enter-env() {
      local return_status=$?
      (( in_env++ ))
      options=( $env_options )
      if [[ $1 == --not-subcontext || $2 == --not-subcontext ]] {
        env_subcontext+=( 1 )
      } else {
        options[errexit]=off
        env_subcontext+=( 0 )
      }
      if [[ $1 == --passthrough-status || $2 == --passthrough-status ]] {
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
      if (( in_env > 0 )) {
        (( in_env-- )) || true
        if (( env_subcontext[-1] )) {
          options[errexit]=$env_options[4]
        }
        env_subcontext=( $env_subcontext[1,-2] )
        env_options=( extended_glob $options[extended_glob] errexit $options[errexit] )
        options=( $normal_options )
        if (( in_env )) {
          options=( $env_options )
          if (( !env_subcontext[-1] )) {
            options[errexit]=off
          }
        }
      }
      builtin return $return_status
    }
    define:push-stack() {
      if (( $#stack >= 63 )) {
        define:error stack overflow
        exit
      } else {
        stack+=$1;
        stack_type+=$2;
        stack_line+=$lineNo;
        stack_autopop+=$temp_autopop;
      }
    }
    define:pop-stack() {
      local -A corresponding_type=(
        for 1
        while 1
        function 2
      )
      if [[ $corresponding_type[$stack_type[-1]] == 1 && $stack[-1] == 0 ]] {
        lineNo=$(( stack_line[-1] - 1 ))
        cont_loop=1
        builtin return 1
      }
      if [[ $corresponding_type[$stack_type[-1]] == 2 && $stack[-1] == 0 ]] {
        in_function=0
        if (( in_iife )) {
          builtin eval 'define:call "$in_function_name"' ${command##\#(@(<->[[:space:]]|)|)(+|)end([[:space:]]|)}
        }
        in_iife=0 in_function_name=
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
      builtin print -u2 $funcstack[2]${*:+: $*};
      define:enter-env --not-subcontext
      define:return-status 1
      define:exit-env --ignore-status
    }
    define:call() {
      local start_lineNo=$functions_start[$1]
      if [[ -z $start_lineNo ]] {
        define:error function not found: "${(q)1}"
        builtin return 1
      }
      builtin shift
      local -a function_params=( "$@" )
      define:enter-env --not-subcontext;
      "$name_of_self" $'\0function' "$1" "${(@)internal_args}"
      define:exit-env
    }
    call() {
      define:call "$@"
    }
    define:return-status() {
      builtin return $1
    }
  }

  define:exit-env;

  local context_name=${function_name:-$1}
  if (( !function_mode )) {
    local -a lines
    while { builtin read -r line || [[ $line ]] } {
      lines+=$line
    } < $1
    local -A functions_start labels
    lineNo=1
  } else {
    local -A functions_start=( "${(@kv)functions_start}" )
    local -A labels=( "${(@kv)labels}" )
    lineNo=$(( start_lineNo + 1 ))
  }
  builtin unset line
  builtin shift

  local -a internal_args=( "$@" )
  if [[ $1 == $name_of_self ]] {
    argv=($argv[1] $'\0' $argv[2,-1])
  }
  if [[ $1 == "--" ]] {
    builtin shift
  }

  prepend_command=( "$@" )
  argv=( "${(@)function_args}" )

  for (( ; lineNo <= $#lines; lineNo++ )) {
    local temp_autopop=0 allow_clean_stack=1 command=$lines[$lineNo] cont_loop=0 statements=()
    if (( lineNo > $#lines )) {
      command="# EOF: ${(q)context_name}"
    } elif (( lineNo < 1 )) {
      command="# BOF: ${(q)context_name}"
    }
    if (( ZSH_DEBUG )) {
      builtin print $context_name$'\t'$lineNo$'\t'"${${:-0${(j"")stack}}:---}"\
      $'\t'${stack_line[-1]:---}$'\t'${stack_type[-1]:---}$'\t'${stack_autopop[-1]:---}$'\t'${(@q)command}
    }

    if (( in_function || function_mode )) {
      if (( allow_clean_stack )) {
        while (( $#stack && stack_autopop[-1] == -2 )) {
          if { ! define:pop-stack; } {
            break
          }
        }
      }
      if [[ $command == \#(@(<->[[:space:]]|)|)(+|)end([[:space:]]*|) ]] {
        if (( in_function )) {
          while (( $#stack )) {
            if { ! define:pop-stack; } {
              break
            }
          }
        } else {
          break
        }
      }
      if (( in_function )) {
        continue
      }
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
      local data="${${command#\#}#$action}"
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
          if (( 0${(j"")stack} == 0 )) {
            if (( function_mode )) {
              define_exit_status=$data
              break
            } else {
              define:enter-env --not-subcontext
              define:return-status $data
              define:exit-env
            }
          }; ;;
        (call)
          local function_name=${trimmed_data%%[[:space:]]*}
          if [[ -z $function_name ]] {
            define:error invalid function name: "${(q)trimmed_data}"
          } else {
            builtin eval 'define:call "$function_name"' ${data##[[:space:]]#$function_name}
          };;
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
        (function) 
          if [[ $trimmed_data == *[[:space:]]* ]] {
            define:error invalid function name: "${(q)trimmed_data}"
            define:push-stack 1 function
          } else {
            if [[ -z $trimmed_data ]] {
              in_iife=1
            }
            functions_start[$trimmed_data]=$lineNo
            in_function=1
            in_function_name=$trimmed_data
            define:push-stack 0 function
          };;
        (end);&
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
            function end
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
  builtin print -u2 $funcstack[2]${*:+: $*};
}

console:log() {
  builtin emulate -L zsh
  builtin print -u1 $funcstack[2]${*:+: $*};
}
