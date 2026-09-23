() {
  builtin enable emulate zmodload eval echoti
  builtin emulate -L zsh
  builtin zmodload zsh/terminfo
  local id;
  for id ( $reply ) {
    [[ -n $terminfo[$id] ]] && builtin eval builtin echoti "$id"
  }
}
