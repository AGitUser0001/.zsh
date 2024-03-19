() {
  builtin enable emulate zmodload eval echoti
  builtin emulate -L zsh
  builtin zmodload zsh/terminfo
  local id;
  for id ( $reply ) {
    builtin eval builtin echoti "$id"
  }
}
