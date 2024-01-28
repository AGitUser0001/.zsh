autoload -Uz $fpath[1]/zle/**/--?*(-N^/)
zle -A emacs-forward-word forward-word

() {
  local i
  for i ( $functions[(I)--?*] ) {
    [[ $functions_source[$i] == $fpath[1]/zle/(*/|)--?* ]] && zle -N -- "${i#--}" "$i"
  }

  local del=( '^Q' '^S' )
  bindkey "${(ps"\xFF")${(pj"\xFFblank-key\xFF")del}}" blank-key

  local map=(
    # command line help
    '^[H'             run-help            '^[h'         run-help

    # delete and insert
    '^[('             delete-word         '^[[3;5~'     delete-word
    '^[[7;5~'         backward-delete-word

    # buffer operations
    '^Z'              undo                '^R'          redo
    '^[q'             push-line-or-edit   '^[Q'         push-line-or-edit
    

    # cursor movement
    '^[[H'            beginning-of-line   '^[[1;5D'     backward-word
    '^[[F'            end-of-line         '^[[1;5C'     forward-word

    # history search
    '^[[5~'           history-incremental-search-backward
    '^[[6~'           history-incremental-search-forward

    # other
    '^[[I'            zle-focus           '^[[O'        zle-blur
    '^D'              exit

    # menu completion
    '^I'              menu-complete       '^[[Z'        reverse-menu-complete
    -q -M menuselect  '^[[1;2C'           history-incremental-search-forward
    -q -M menuselect  '^[[1;2D'           history-incremental-search-backward
    -q -M menuselect  '^[^M'              accept-and-infer-next-history
    -q -M menuselect  '^[[5~'             backward-word
    -q -M menuselect  '^[[6~'             forward-word
    -q -M menuselect  '^[[5~'             backward-word
    -q -M menuselect  '^[[Z'              reverse-menu-complete
    -q -M menuselect  '^['                send-break
  )

  (( $+widgets[zle-focus] ))  ||  map+=( '^[[I' blank-key )
  (( $+widgets[zle-blur] ))   ||  map+=( '^[[O' blank-key )

  local j=0 l=( ) q=1 p=0
  local -A o=( )
  
  for i ( "$map[@]" ) {
    l+=( "$i" )

    if (( p && p-- )) continue

    (( j++ ))
    if (( ! o[-] )) case $i {
      (^-*) o[-]=1;;
      (*) (( j-- ));|
      (-(-|)) o[-]=1;;
      (-[M]*) (( $#i == 2 && p++ ));;
      (-[evasR]) ;;
      (-[r]) (( $o[$i] || j++ ));;
      (-[q]) q=\& l[-1]=( );;
      (-[p])
        if (( ! o[-r] )) {
          _err not valid in this context: $i
          j=2 l=( )
        }
        ;;
      (-[lLdDANm])
        _err not valid in this context: $i
        j=2 l=( );;
      (*)
        _err bad option: $i
        j=2 l=( );;
    }

    (( o[-] )) || o[$i]=1

    if (( j == 2 )) {
      eval 'bindkey "$l[@]"' $q'> /dev/null'
      j=0 k=0 l=( ) o=( ) q=1 p=0
    }
  }
}
