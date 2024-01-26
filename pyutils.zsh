py() {
  if [[ $0 == py ]] {
    python3 "$@"
  } else {
    ${0/py/python} "$@"
  }
}

() {
  local name
  for name ( ${commands[(I)python([0-9]##((.~?(#e))|(#e)))(#c0,2)]} ) {
    name=py${name:6}

    functions -c py $name
  }
}
