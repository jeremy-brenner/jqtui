#!/usr/bin/env bash

source terminal.sh
source box.sh
source style.sh

readKeyTimeout=0.01
readFromBackendTimeout=0.03

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
  echo "${1}" >> jqtui.log
}

package() {
  jq -nc --argjson i "${i}" --argjson w "${w}" --argjson h "${h}" --arg style "${style}" --argjson screen "${screen}" '{ $i, $w, $h, $style, $screen }'
}

send() {
  log "Calling send"
  local _next="$(package)"
  ((i++))
  jq -nc --argjson prev "${prev}" --argjson next "${_next}" '{ $prev, $next }' >&${backendWriteFd}
  prev="${_next}"
}

readKey() {
  escape_char=$(printf "\\u1b")
  IFS= read -t $readKeyTimeout -rsn1 -d '' mode < /dev/tty
  if [[ $? -gt 128 ]]; then
    mode='TIMEOUT'
  fi
  if [[ $mode == $escape_char ]]; then
    read -rsn2 mode < /dev/tty
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
}

readFromBackend() {
  log "reading from backend"
  backendReadFd="${1}"
  read -t $readFromBackendTimeout -d '' -r -u "${backendReadFd}" results
  if [[ -n "${results}" ]]; then
    printf -- '%s' "${results}"
    log "got results ========="
    log "${results}"
    log "end results ========="
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

firstMenuItemCount=${#firstMenuItemNames[@]}

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

renderFirstMenu() {
  log "Calling render"
  jq -R '[.]' <<< "$( box::topRow "${w}" "$(date)" )"
  for x in $(seq 0 $(( firstMenuItemCount - 1 )) ); do
    highlight="false"
    if [[ "${x}" == "${cursor}" ]]; then
      highlight="true"
    fi
    log "x: ${x} cursor: ${cursor} high: ${highlight}"
    jq -R '[.]' <<< "$( box::optionRow "${w}" "${firstMenuItemNames[x]}" "${highlight}" "false" )"
  done
  for x in $(seq $(( firstMenuItemCount - 1 )) $(( h - 4 )) ); do
    jq -R '[.]' <<< "$( box::emptyRow "${w}" )"
  done
  jq -R '[.]' <<< "$( box::bottomRow "${w}" )"
}

doRender() {
  screen="$(jq -s 'add' < <(renderFirstMenu) )"
  send
}

cursor=1

handleKey() {
  _key="${1}"
  if [[ -n "${_key}" ]]; then
    if [[ "${_key}" == "UP" ]]; then
      cursor=$(( (cursor - 1 + firstMenuItemCount) % firstMenuItemCount ))
    fi
    if [[ "${_key}" == "DOWN" ]]; then
      cursor=$(( (cursor + 1) % firstMenuItemCount ))
    fi
  fi
}

while :; do
  _key=$(readKey)
  case $_key in
    'q') break ;;
    'TIMEOUT') checkTermSize ;;
    *) handleKey "${_key}";;
  esac
  doRender
  readFromBackend "${backendReadFd}"
done
