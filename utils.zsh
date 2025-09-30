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
  local nested_define=0 function_mode=0 function_begin=0 function_name= name_of_self=$funcstack[1]
  local tail_call=0 tail_call_result=
  local -a function_args=( )
  if [[ $1 == $'\0function' ]] {
    function_mode=1 function_begin=1
    function_args=( "${(@)function_params}" )
    function_name=$2
  }
  if [[ $1 == $'\0'* ]] {
    nested_define=1
    builtin shift
  } elif (( funcstack[(Ie)$name_of_self] > 1 )) {
    nested_define=1
  }
  case $# {
    (0) builtin print -u2 "Usage: $name_of_self <file> [<command>]"; builtin return 1;;
    (1) 2=$name_of_self;;
  }
  local prepend_args env_status=0 in_env=1 define_exit_status=0 line lineNo iter_var=0
  local define_exit_result=0 define_use_exit_result=0
  local -T STACK stack=( )
  local -T STACK_TYPE stack_type=( )
  local -T STACK_LINE stack_line=( )
  local -T STACK_AUTOPOP stack_autopop=( )
  local -a prepend_command env_subcontext normal_options=( extended_glob on errexit off ) env_options
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
      define:find-last-context-type
      local ctype=$?
      define:find-last-context
      local cindex=$?
      if [[ $1 == --meta && $cindex != $#stack ]] {
        cindex=0 ctype=0
      } elif [[ $1 == --force ]] {
        cindex=0 ctype=0
      }
      if (( ctype == 1 && stack[$cindex] == 0 )) {
        while (( $#stack > cindex )) {
          if { ! define:pop-stack --meta; } {
            builtin return 1
          }
        }
        if (( stack_line[-1] != lineNo )) {
          lineNo=$(( stack_line[-1] - 1 ))
          cont_loop=1
        } else {
          #define:pop-stack --force
        }
        builtin return 1
      }
      if (( ctype == 2 && stack[$cindex] == 0 )) {
        while (( $#stack > cindex )) {
          if { ! define:pop-stack --meta; } {
            builtin return 1
          }
        }
        define:pop-stack --force
        functions_end[$in_function_name]=$lineNo
        in_function=0
        if (( in_iife )) {
          builtin eval 'define:call "$in_function_name"' ${command##\#(@(<->[[:space:]]|)|)(+|)end([[:space:]]|)}
        }
        in_iife=0 in_function_name=
        builtin return 1
      }
      builtin shift -p stack stack_type stack_line stack_autopop
    }
    define:find-last-index() {
      local max_last_index=0
      while (( $#argv )) {
        local last_index=$stack_type[(Ie)$1]
        if (( last_index > max_last_index )) {
          max_last_index=$last_index
        }
        shift
      }
      builtin return $max_last_index
    }
    define:find-last-context-type() {
      local -A corresponding_type=(
        for 1
        repeat 1
        while 1
        until 1
        function 2
        switch 3
      )
      define:find-last-index for repeat while until function switch
      builtin return $corresponding_type[$stack_type[$?]]
    }
    define:find-last-context() {
      define:find-last-index for repeat while until function switch
      builtin return $?
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
        local token_pos=${tokens[(ie);]}
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
      local call_target=$1
      define:call-check-lineNo $call_target || builtin return $?
      if (( tail_call )) {
        tail_call=0
        if (( function_mode )) {
          start_lineNo=$functions_start[$call_target]
          end_lineNo=$functions_end[$call_target]
          builtin shift
          stack=( ) stack_type=( ) stack_line=( ) stack_autopop=( ) frame_data=( )
          if [[ -n $tail_call_result && $define_use_exit_result == 0 ]] {
            define_exit_result=$tail_call_result define_use_exit_result=1
          }
          in_function=0 in_iife=0 in_function_name= define_exit_status=0 tail_call_result=
          lineNo=$start_lineNo
          for (( iter_var = start_lineNo + 1; iter_var < end_lineNo; iter_var++ )) {
            unset "ast_stack[$iter_var]" "ast_type[$iter_var]" "ast_line[$iter_var]" "ast_autopop[$iter_var]"
          }
          function_begin=1
          function_name=$call_target
          function_params=( "$@" )
          function_args=( "${(@)function_params}" )
          cont_loop=1
          builtin return 0
        }
      }
      local start_lineNo=$functions_start[$call_target]
      local end_lineNo=$functions_end[$call_target]
      builtin shift
      local -a function_params=( "$@" )
      define:enter-env --not-subcontext;
      "$name_of_self" $'\0function' "$call_target" "${(@)internal_args}"
      define:exit-env
    }
    define:call-check-lineNo() {
      local call_target=$1
      local start_lineNo=$functions_start[$call_target]
      local end_lineNo=$functions_end[$call_target]
      if [[ -z $start_lineNo ]] {
        define:error function not found: "${(q)call_target}"
        builtin return 1
      }
      if [[ -z $end_lineNo ]] {
        define:error end of function not found: "${(q)call_target}"
        builtin return 1
      }
    }
    define:return-status() {
      builtin return $1
    }
    define:ast-snapshot() {
      if (( !$+ast_stack[$1] )) {
        ast_stack[$1]=${STACK//[^:]##/0}
        ast_type[$1]=$STACK_TYPE
        ast_line[$1]=
        for iter_var ( "${(@)stack_line}" ) {
          local ctx_comma="${line_contexts[$iter_var]},"
          ast_line[$1]+="${${(@k)remap_lines[(R)$iter_var]}[(R)$ctx_comma*]}:"
        }
        ast_line[$1]="${ast_line[$1]%:}"
        ast_autopop[$1]=$STACK_AUTOPOP
      }
    }
    define:ast-restore() {
      if [[ -n $ast_stack[$1] ]] {
        STACK=$ast_stack[$1]
      }
      if [[ -n $ast_type[$1] ]] {
        STACK_TYPE=$ast_type[$1]
      }
      if [[ -z $ast_line[$1] ]] {
        stack_line=( )
      } else {
        STACK_LINE=$ast_line[$1]
        for (( iter_var = 1; iter_var <= $#stack_line; iter_var++ )) {
          stack_line[$iter_var]=$remap_lines[$stack_line[$iter_var]]
        }
      }
      if [[ -n $ast_autopop[$1] ]] {
        STACK_AUTOPOP=$ast_autopop[$1]
      }
      (( $+ast_stack[$1] ))
    }
  }

  define:exit-env;

  local context_name=${function_name:-$1}
  if (( !function_mode )) {
    local -a lines line_contexts
    local -A functions_start functions_end labels remap_lines
    local -A ast_stack ast_type ast_line ast_autopop
    local last_context_id=0
    while { builtin read -r line || [[ $line ]] } {
      lines+=$line
      line_contexts+="$last_context_id"
      remap_lines[$last_context_id,$#lines]=$#lines
    } < $1
    lineNo=1
  } else {
    local -A functions_start=( "${(@kv)functions_start}" ) functions_end=( "${(@kv)functions_end}" )
    local -A labels=( "${(@kv)labels}" ) remap_lines=( "${(@kv)remap_lines}" )
    local -a lines=( "${(@)lines}" ) line_contexts=( "${(@)line_contexts}" )
    local -A ast_stack=( "${(@kv)ast_stack}" ) ast_type=( "${(@kv)ast_type}" )
    local -A ast_line=( "${(@kv)ast_line}" )   ast_autopop=( "${(@kv)ast_autopop}" )
    lineNo=$(( start_lineNo + 1 ))
    for (( iter_var = start_lineNo + 1; iter_var < end_lineNo; iter_var++ )) {
      unset "ast_stack[$iter_var]" "ast_type[$iter_var]" "ast_line[$iter_var]" "ast_autopop[$iter_var]"
    }
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
  argv=( )

  for (( ; lineNo <= $#lines; lineNo++ )) {
    if (( function_begin )) {
      argv=( "${(@)function_args}" )
    }
    local temp_autopop=0 allow_clean_stack=1 command=$lines[$lineNo] cont_loop=0 statements=()
    if (( lineNo > $#lines )) {
      command="# EOF: ${(q)context_name}"
    } elif (( lineNo < 1 )) {
      command="# BOF: ${(q)context_name}"
    } else {
      define:ast-snapshot $lineNo
    }
    if (( ZSH_DEBUG )) {
      builtin print $context_name$'\t'$lineNo$'\t'"${${:-${(j"")stack}}:---}"\
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
        (prepend) prepend_args="$data";;
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
            stack_autopop[-1]=$temp_autopop
          }; ;;
        (repeat) if (( stack_line[-1] != lineNo )) {
                   frame_data[$lineNo]="${(e)trimmed_data}"
                   if [[ $frame_data[$lineNo] != <-> ]] {
                     define:error invalid repeat value: "${(q)frame_data[$lineNo]}"
                     define:push-stack 1 repeat
                   } else {
                     define:push-stack 0 repeat
                   }
                 } else {
                   (( frame_data[$lineNo]-- ))
                   stack_autopop[-1]=$temp_autopop
                 }
                 if (( frame_data[$lineNo] <= 0 )) {
                   stack[-1]=1
                 }; ;;
        (while)
          if (( stack_line[-1] != lineNo )) {
            define:enter-env; builtin eval "$data"; define:exit-env
            define:push-stack $? while
          } else {
            define:enter-env; builtin eval "$data"; define:exit-env
            stack[-1]=$?
            stack_autopop[-1]=$temp_autopop
          }; ;;
        (until)
          if (( stack_line[-1] != lineNo )) {
            define:enter-env; builtin eval "$data"; define:exit-env
            define:push-stack $(( $? == 0 )) until
          } else {
            define:enter-env; builtin eval "$data"; define:exit-env
            stack[-1]=$(( $? == 0 ))
            stack_autopop[-1]=$temp_autopop
          }; ;;
        (switch)
          define:push-stack 0 switch;
          define:enter-env;
          frame_data[$lineNo]="${(e)trimmed_data}"
          define:exit-env --ignore-status;;
        (case)
          define:clean-stack; if (( cont_loop )) { continue; }
          if [[ $stack_type[-1] == case && $stack[-1] != 0 ]] {
            define:pop-stack; if (( cont_loop )) { continue; } 
          }
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
        (case-regex)
          define:clean-stack; if (( cont_loop )) { continue; }
          if [[ $stack_type[-1] == case && $stack[-1] != 0  ]] {
            define:pop-stack; if (( cont_loop )) { continue; } 
          }
          if [[ $stack_type[-1] == case ]] {
            local prev_case_status=$stack[-1]
            define:pop-stack; if (( cont_loop )) { continue; } 
            define:push-stack $prev_case_status case;
          } elif [[ $stack_type[-1] == switch ]] {
            if [[ $stack[-1] == 0 ]] {
              local switch_data=$frame_data[$stack_line[-1]]
              local regexp_flags=
              if [[ $trimmed_data == /*/* ]] {
                regexp_flags=${trimmed_data[ ${trimmed_data[(Ie)/]} + 1, -1 ]}
                trimmed_data=${trimmed_data[ 2, ${trimmed_data[(Ie)/]} - 1 ]}
              }
              local options_casematch=$options[casematch]
              if [[ $regexp_flags == [imsxUXJ]# ]] {
                if [[ $options[rematchpcre] == on ]] {
                  if (( $#regexp_flags )) {
                    trimmed_data="(?$regexp_flags)$trimmed_data"
                  }
                } else {
                  if [[ $regexp_flags == i## ]] {
                    options[casematch]=off;
                  } else {
                    if (( $#regexp_flags )) {
                      define:error invalid regexp flags: $regexp_flags
                    }
                    options[casematch]=on;
                  }
                }
              } else {
                define:error invalid regexp flags: $regexp_flags
              }
              define:enter-env
              [[ "$switch_data" =~ ${~trimmed_data} ]]
              define:exit-env --ignore-status
              define:push-stack $? case;
              options[casematch]=$options_casematch
            } else {
              define:push-stack 1 case;
            }
          } else {
            define:error invalid action in context: $action
          };;
        (include)
          local include_file=${(e)trimmed_data}
          if [[ ! -r $include_file ]] { 
            define:error include file not found: "${(q)include_file}"
          } else {
            define:enter-env --not-subcontext
            local line include_lines=( ) include_line_contexts=( ) include_start=$lineNo
            (( last_context_id++ ))
            while { builtin read -r line || [[ $line ]] } {
              include_lines+=$line
              include_line_contexts+=$last_context_id
            } < $include_file
            if (( !$#include_lines )) {
              include_lines+=""
              include_line_contexts+=$last_context_id
            }
            local include_end=$(( lineNo - 1 + $#include_lines ))
            local include_length=$(( include_end - lineNo ))
            unset line
            lines=( "${(@)lines[1,$((lineNo-1))]}" "${(@)include_lines}" "${(@)lines[$((lineNo+1)),-1]}" )
            line_contexts=( "${(@)line_contexts[1,$((lineNo-1))]}" "${(@)include_line_contexts}" "${(@)line_contexts[$((lineNo+1)),-1]}" )
            local remap_val=
            for iter_var remap_val ("${(@kv)remap_lines}") {
              if (( remap_val > include_start )) {
                remap_lines[$iter_var]=$(( remap_val + include_length ))
              }
            }
            for  (( iter_var = include_start; iter_var <= include_end; iter_var++ )) {
              remap_lines[$last_context_id,$iter_var]=$iter_var
            }
            typeset remap_lines
            for iter_var remap_val ("${(@kv)stack_line}") {
              if (( remap_val > include_start )) {
                stack_line[$iter_var]=$(( remap_val + include_length ))
              }
            }
            for iter_var remap_val ("${(@kv)functions_start}") {
              if (( remap_val > include_start )) {
                functions_start[$iter_var]=$(( remap_val + include_length ))
              }
            }
            for iter_var remap_val ("${(@kv)functions_end}") {
              if (( remap_val > include_start )) {
                functions_end[$iter_var]=$(( remap_val + include_length ))
              }
            }
            for iter_var remap_val ("${(@kv)labels}") {
              if (( remap_val > include_start )) {
                labels[$iter_var]=$(( remap_val + include_length ))
              }
            }
            for (( iter_var=$#ast_stack; iter_var > include_start; iter_var-- )) {
              if (( !$+ast_stack[$1] )) { continue; }
              (( remap_val = iter_var + include_length ))
              ast_stack[$remap_val]=$ast_stack[$iter_var]
              ast_type[$remap_val]=$ast_type[$iter_var]
              ast_line[$remap_val]=$ast_line[$iter_var]
              ast_autopop[$remap_val]=$ast_autopop[$iter_var]
              unset "ast_stack[$iter_var]" "ast_type[$iter_var]" "ast_line[$iter_var]" "ast_autopop[$iter_var]"
            }
            unset remap_val
            ((lineNo--)); continue
          };;
        (elif) stack_autopop[-1]=$temp_autopop
               if (( stack[-1] )) {
                 define:enter-env; builtin eval "$data"; define:exit-env
                 stack[-1]=$?
               } else { stack[-1]=0 } ;;
        (else) stack[-1]=$(( !stack[-1] )); stack_autopop[-1]=$temp_autopop;;
        (return)
          if (( 0${(j"")stack} == 0 )) {
            if (( function_mode )) {
              if [[ -z $trimmed_data ]] {
                define_exit_status=$data
              }
              break
            } else {
              define:enter-env --not-subcontext
              define:return-status $data
              define:exit-env
            }
          }; ;;
        (call)
          if (( 0${(j"")stack} == 0 )) {
            local call_target=${trimmed_data%%[[:space:]]*}
            if [[ -z $call_target ]] {
              define:error invalid function name: "${(q)trimmed_data}"
            } else {
              builtin eval 'define:call "$call_target"' ${data##[[:space:]]#$call_target}
              if (( cont_loop )) { continue; }
            }
          }; ;;
        (call-and-return)
          if (( 0${(j"")stack} == 0 )) {
            local call_target=${trimmed_data%%[[:space:]]*}
            if [[ -z $call_target ]] {
              define:error invalid function name: "${(q)trimmed_data}"
            } else {
              tail_call=1
              builtin eval 'define:call "$call_target"' ${data##[[:space:]]#$call_target}
              if (( cont_loop )) { continue; }
            }
            if (( function_mode )) {
              define_exit_status=$env_status
              break
            }
          }; ;;
        (call-and-end)
          if (( function_mode )) {
            if (( 0${(j"")stack} == 0 )) {
              local call_target=${trimmed_data%%[[:space:]]*}
              if [[ -z $call_target ]] {
                define:error invalid function name: "${(q)trimmed_data}"
              } else {
                tail_call=1 tail_call_result=$define_exit_status
                builtin eval 'define:call "$call_target"' ${data##[[:space:]]#$call_target}
                if (( cont_loop )) { continue; }
              }
              if (( function_mode )) {
                break
              }
            }
          } else {
            define:error invalid action in context: $action
          }; ;;
        (set-return)
          if (( function_mode )) {
            if (( 0${(j"")stack} == 0 )) {
              define_exit_status=$data
            }
          } else {
            define:error invalid action in context: $action
          }; ;;
        (label) if [[ $trimmed_data == <-> || -z $trimmed_data ]] {
                  define:error invalid label: "${(q)trimmed_data}"
                } else {
                  labels[$trimmed_data]=$lineNo
                };;
        (goto) if (( 0${(j"")stack} == 0 )) {
                 if [[ $trimmed_data == <-> ]] {
                   local goto_lineNo=$trimmed_data
                   goto_lineNo=$remap_lines[$line_contexts[$lineNo],$goto_lineNo]
                   if (( !goto_lineNo )) {
                     define:error out of bounds: "${(q)trimmed_data}"
                   } else {
                     lineNo=$(( goto_lineNo - 1 ))
                     define:ast-restore $lineNo
                   }
                   continue
                 } else {
                   if [[ -n $labels[$trimmed_data] ]] {
                     local goto_lineNo=$labels[$trimmed_data]
                     goto_lineNo=$remap_lines[$line_contexts[$lineNo],$goto_lineNo]
                     if (( !goto_lineNo )) {
                       define:error out of bounds: "${(q)trimmed_data}"
                     } else {
                       lineNo=$(( goto_lineNo - 1 ))
                       define:ast-restore $lineNo
                     }
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
        (break);&
        (continue);&
        (end);&
        (done);&
        (endif)
          define:clean-stack; if (( cont_loop )) { continue; }
          define:find-last-context-type
          local ctype=$?
          define:find-last-context
          local cindex=$?
          if [[ $action == continue ]] {
            if (( ctype == 1 )) {
              if (( stack[$cindex] == 0 )) {
                while (( $#stack > cindex )) {
                  if { ! define:pop-stack; } {
                    break
                  }
                }
                if (( $#stack == cindex )) {
                  lineNo=$(( stack_line[-1] - 1 ))
                  cont_loop=1
                }
                if (( cont_loop )) { continue; }
              }
            } elif (( ctype == 3 )) {
              if (( $#stack > cindex )) {
                stack[$((cindex + 1))]=1
              } else {
                stack[$cindex]=1
              }
            } else {
              define:error invalid action in context: $action
            }
          } elif [[ $action == break ]] {
            if (( ctype == 1 || ctype == 3 )) {
              if (( stack[$cindex] == 0 )) {
                stack[$cindex]=1
              }
            } else {
              define:error invalid action in context: $action
            }
          } else {
            local -A corresponding_actions=(
              if endif
              for done
              repeat done
              while done
              until done
              switch done
              function end
            )
            if [[ $stack_type[-1] == case && $stack_type[-2] == switch \
                  && $action == $corresponding_actions[$stack_type[-2]] ]] {
              define:pop-stack; if (( cont_loop )) { continue; }
              define:pop-stack; if (( cont_loop )) { continue; }
            } elif [[ $corresponding_actions[$stack_type[-1]] == $action ]] {
              define:pop-stack; if (( cont_loop )) { continue; }
            } else {
              define:error invalid action in context: $action
            }
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
      for (( iter_var = 1; iter_var <= $#stack_autopop; iter_var++ )) {
        if (( stack_autopop[iter_var] > 0 )) {
          (( stack_autopop[iter_var]-- ))
          if (( stack_autopop[iter_var] == 0 )) {
            stack_autopop[$iter_var]=-2
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
  if (( define_use_exit_result )) {
    builtin return $define_exit_result
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
