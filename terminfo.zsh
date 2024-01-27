() {
  builtin emulate -LR zsh
  builtin zmodload zsh/terminfo
  local id;
  for id ( $reply ) {
    builtin eval builtin echoti "$id"
  }
}
