source terminal.sh

getColor() {
  local _isCurrent="${1}"
  local _default="${2}"

  if [[ "${_isCurrent}" == "true" ]]; then
    if [[ -n "${_default}" ]]; then
      echo -en "${_default}"
    else
      terminal::white
    fi
  else
    terminal::grey
  fi
}

box::topRow() {
  local _w="${1}"
  local _title="${2}"
  local _isCurrent="${3}"
  local _title_len="${#_title}"
  local _middleBits=$(( _w - 4 - _title_len ))

  printf -- "$(getColor "${_isCurrent}")${STYLE_TOPLEFT}"
  printf -- "${STYLE_TOPMIDDLE}%.0s" $(seq 1 $((_middleBits/2 + _middleBits%2)));
  printf -- "${STYLE_TITLEHOLESTART}$(getColor "${_isCurrent}" $(terminal::green))${_title}$(getColor "${_isCurrent}" $(terminal::resetAll))${STYLE_TITLEHOLEEND}"
  printf -- "${STYLE_TOPMIDDLE}%.0s" $(seq 1 $((_middleBits/2)));
  printf -- "${STYLE_TOPRIGHT}"
  printf -- "\n"
}

box::optionRow() {
  local _w="${1}"
  local _option="${2}"
  local _highlight="${3}"
  local _selected="${4}"
  local _isCurrent="${5}"
  local _title_len="${#_option}"

  printf -- "$(getColor "${_isCurrent}")${STYLE_SIDECOL} "
  if [[ "${_highlight}" == "true" ]]; then
     printf -- "$(terminal::invert)"
  fi
  if [[ "${_selected}" == "true" ]]; then
    printf -- "${STYLE_SELECTED}%*s" $(( _w - 5 )) "${_option}"
  else
    printf -- "%*s" $(( _w - 4 )) "${_option}"
  fi

    printf -- "$(terminal::resetAll)$(getColor "${_isCurrent}")"

  printf -- " ${STYLE_SIDECOL}"
  printf -- "\n"
}


box::emptyRow() {
  local _w="${1}"
  local _isCurrent="${2}"

  printf -- "$(getColor "${_isCurrent}")${STYLE_SIDECOL}"
  printf -- "%*s" $(( _w - 2 ))
  printf -- "${STYLE_SIDECOL}"
  printf -- "\n"
}

box::bottomRow() {
  local _w="${1}"
  local _isCurrent="${2}"
  printf -- "$(getColor "${_isCurrent}")${STYLE_BOTTOMLEFT}"
  printf -- "${STYLE_BOTTOMMIDDLE}%.0s" $(seq 1 $(( _w - 2 )));
  printf -- "${STYLE_BOTTOMRIGHT}"
  printf -- "\n"
}



