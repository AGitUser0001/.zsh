() {
  local name
  for name ( ${commands[(I)python([0-9]##((.~?(#e))|(#e)))(#c0,2)]} ) {
    pyname=py${name:6}

    alias $pyname=$name
    alias py=$name
  }
}
