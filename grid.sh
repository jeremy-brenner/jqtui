#!/usr/bin/env bash


function list() {
  for i in $(seq 0 255); do
    char="$(printf "%02X" $i)"
    echo -n "\u25${char} "
    echo -e "\u25${char}"
  done
}

printPipes="false"
space=" "
if [[ "${printPipes}" == "true" ]]; then
  space="\u2502"
fi

function grid() {
  echo "U+25xx"
  echo "  " {0..9} {A..F}
  for row in {0..9} {A..F}; do
    if [[ "${printPipes}" == "true" ]]; then
      echo -ne "\u2500"
      printf -- "\u2500\u253C%.0s" {0..9} {A..F}; echo -e "\u2500\u253C"
    fi
    echo -ne "${row}x${space}"
    echo -en $(printf "\\\u25${row}%s${space}" {0..9} {A..F})
    echo
  done
}

grid``
