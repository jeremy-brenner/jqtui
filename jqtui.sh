#!/usr/bin/env bash

source terminal.sh
source box.sh
source style.sh

readFromBackendTimeout=0.02

./build.sh
sleep 0.5

terminal::hijackTerm
w="$(terminal::getWidth)"
h="$(terminal::getHeight)"
i=0
style="basic"
prev='null'

coproc backendProc {
  jq --unbuffered -r --slurpfile styles style.json -L ./out 'include "jqtui"; compareBuffers | print'
}

exec 10<&"${backendProc[0]}"
exec 11>&"${backendProc[1]}"

backendReadFd=10
backendWriteFd=11

log() {
  echo $(date +%s.%N) "${1}" >> jqtui.log
}

package() {
  jq -nc --argjson i "${i}" --argjson w "${w}" --argjson h "${h}" --arg style "${style}" --argjson screen "${screen}" '{ $i, $w, $h, $style, $screen }'
}

send() {
  local _next="$(package)"
  ((i++))
  jq -nc --argjson prev "${prev}" --argjson next "${_next}" '{ $prev, $next }' >&${backendWriteFd}
  prev="${_next}"
}


readKey() {
  escape_char=$(printf "\\u1b")
  if IFS= read -t0 -s -d '' ; then
    IFS= read -rsn1 -d '' mode
    if [[ $mode == $escape_char ]]; then
      read -rsn2 mode
    fi
    case $mode in
       $'\t') echo "TAB";;
       $'\n') echo "ENTER";;
      '[A') echo "UP" ;;
      '[B') echo "DOWN" ;;
      '[D') echo "LEFT" ;;
      '[C') echo "RIGHT" ;;
      ' ') echo "SPACE";;
      *) echo $mode ;;
    esac
  fi
}


readFromBackend() {
  backendReadFd="${1}"
  read -t $readFromBackendTimeout -d '' -r -u "${backendReadFd}" results
  if [[ -n "${results}" ]]; then
    printf -- '%s' "${results}"
    log "got results len: ${#results}"
  fi
}

log "jqtui startup"

style::thinrounded

firstMenuItemNames=(
  "First Item"
  "Second Item"
  "Third Item"
  "Fourth Item"
  "Fifth Item"
)

secondMenuItemNames=(
  "Red Item"
  "Green Item"
  "Yellow Item"
  "Purple Item"
  "Blue Item"
)

menuitemcount=()
menuitemcount[0]=${#firstMenuItemNames[@]}
menuitemcount[1]=${#secondMenuItemNames[@]}

checkTermSize() {
  newW="$(terminal::getWidth)"
  newH="$(terminal::getHeight)"

  if [[ -z "${newW}" ]] || [[ -z "${newH}" ]]; then
    return
  fi
  if [[ "${newW}" != "${w}" ]] || [[ "${newH}" != "${h}" ]]; then
    w="${newW}"
    h="${newH}"
  fi
}


cursor=(0 0)
menu=0

renderFirstMenu() {
  local _currentMenu="${1}"
  local _isCurrent="false"
  if [[ "${_currentMenu}" == "0" ]]; then
    _isCurrent="true"
  fi

  box::topRow "${fw}" "$(date)" "${_isCurrent}"
  for x in $(seq 0 $(( menuitemcount[0] - 1 )) ); do
    highlight="false"
    if [[ "${x}" == "${cursor[0]}" ]]; then
      highlight="true"
    fi
     box::optionRow "${fw}" "${firstMenuItemNames[x]}" "${highlight}" "false" "${_isCurrent}"
  done
  for x in $(seq $(( menuitemcount[0] - 1 )) $(( h - 4 )) ); do
    box::emptyRow "${fw}" "${_isCurrent}"
  done
  box::bottomRow "${fw}" "${_isCurrent}"
}

renderSecondMenu() {
  local _currentMenu="${1}"
  local _isCurrent="false"
  if [[ "${_currentMenu}" == "1" ]]; then
     _isCurrent="true"
   fi

  box::topRow "${sw}" "$(date)" "${_isCurrent}"
  for x in $(seq 0 $(( menuitemcount[1] - 1 )) ); do
    highlight="false"
    if [[ "${x}" == "${cursor[1]}" ]]; then
      highlight="true"
    fi
     box::optionRow "${sw}" "${secondMenuItemNames[x]}" "${highlight}" "false" "${_isCurrent}"
  done
  for x in $(seq $(( menuitemcount[1] - 1 )) $(( h - 4 )) ); do
    box::emptyRow "${sw}" "${_isCurrent}"
  done
  box::bottomRow "${sw}" "${_isCurrent}"
}

doRender() {
  fw=$(( w / 3 ))
  sw=$(( w / 3 * 2 ))
  screen=$(jq -n --rawfile first <(renderFirstMenu ${menu}) --rawfile second <(renderSecondMenu ${menu}) '$first | split("\n") | to_entries | map(.value + ($second | split("\n"))[.key])')
  send
}

handleKey() {
  _key="${1}"
  if [[ -n "${_key}" ]]; then
    if [[ "${_key}" == "UP" ]]; then
      cursor[menu]=$(( (cursor[menu] - 1 + menuitemcount[0]) % menuitemcount[0]))
    fi
    if [[ "${_key}" == "DOWN" ]]; then
      cursor[menu]=$(( (cursor[menu] + 1) % menuitemcount[0] ))
    fi
    if [[ "${_key}" == "TAB" ]]; then
      menu=$(( (menu + 1) % 2 ))
    fi
  fi
}

OLD_STTY_CFG=$(stty -g)

stty raw -echo

while :; do
  _key=$(readKey)
  case $_key in
    'q') break ;;
    *) handleKey "${_key}";;
  esac
  doRender
  readFromBackend "${backendReadFd}"
  checkTermSize
done


cleanup() {
  stty "$OLD_STTY_CFG"
  reset
}

trap 'cleanup' EXIT
