autoload -Uz $fpath[1]/zle/**/--?*(-N^/)

() {
  local i
  for i ( $functions[(I)--?*] ) {
    [[ $functions_source[$i] == $fpath[1]/zle/(*/|)--?* ]] && zle -N -- "${i#--}" "$i"
  }
}
