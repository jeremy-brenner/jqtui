

box::topRow() {
  local _w="${1}"
  local _title="${2}"
  local _title_len="${#_title}"
  local _middleBits=$(( _w - 4 - _title_len ))
  printf -- "${STYLE_TOPLEFT}"
  printf -- "${STYLE_TOPMIDDLE}%.0s" $(seq 1 $((_middleBits/2 + _middleBits%2)));
  printf -- "${STYLE_TITLEHOLESTART}${_title}${STYLE_TITLEHOLEEND}"
  printf -- "${STYLE_TOPMIDDLE}%.0s" $(seq 1 $((_middleBits/2)));
  printf -- "${STYLE_TOPRIGHT}"
  printf -- "\n"
}

box::optionRow() {
  local _w="${1}"
  local _option="${2}"
  local _highlight"${3}"
  local _selected="${4}"
  local _title_len="${#_option}"
  printf -- "${STYLE_SIDECOL} "
  if [[ "${_selected}" == "true" ]]; then
    printf -- "${STYLE_SELECTED}%*s" $(( _w - 5 )) "${_option}"
  else
    printf -- "%*s" $(( _w - 4 )) "${_option}"
  fi
  printf -- " ${STYLE_SIDECOL}"
  printf -- "\n"
}


box::emptyRow() {
  local _w="${1}"
  printf -- "${STYLE_SIDECOL}"
  printf -- "%*s" $(( _w - 2 ))
  printf -- "${STYLE_SIDECOL}"
  printf -- "\n"
}

box::bottomRow() {
  local _w="${1}"
  printf -- "${STYLE_BOTTOMLEFT}"
  printf -- "${STYLE_BOTTOMMIDDLE}%.0s" $(seq 1 $(( _w - 2 )));
  printf -- "${STYLE_BOTTOMRIGHT}"
  printf -- "\n"
}



