autoload -Uz $fpath[1]/zle/**/--?*(-N^/)
zle -A emacs-forward-word forward-word

() {
  local i
  for i ( $functions[(I)--?*] ) {
    [[ $functions_source[$i] == $fpath[1]/zle/(*/|)--?* ]] && zle -N -- "${i#--}" "$i"
  }
}
