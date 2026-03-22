#!/usr/bin/env bash

source terminal.sh
source box.sh
source style.sh

timeout=0.05

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

sendKey() {
  _key="${1}"
  if [[ -n "${_key}" ]]; then
    contents="$(jq --arg k "${_key}" '. + [$k]' <<<"${contents}")"
    send
  fi
}

readKey() {
  escape_char=$(printf "\\u1b")
  IFS= read -t $timeout -rsn1 -d '' mode < /dev/tty
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
  read -t $timeout -d '' -r -u "${backendReadFd}" results
  if [[ -n "${results}" ]]; then
    printf -- '%s' "${results}"
    log "got results ========="
    log "${results}"
    log "end results ========="
  fi
}

log "jqtui startup"

style::thinrounded

itemNames=(
  "First Item"
  "Second Item"
  "Third Item"
  "Fourth Item"
  "Fifth Item"
)

itemCount=${#itemNames[@]}

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

renderPage() {
  log "Calling render"
  jq -R '[.]' <<< "$( box::topRow "${w}" "$(date)" )"
  for x in $(seq 0 $(( itemCount - 1 )) ); do
    jq -R '[.]' <<< "$( box::optionRow "${w}" "${itemNames[x]}" "false" "false" )"
  done
  for x in $(seq $(( itemCount - 1 )) $(( h - 4 )) ); do
    jq -R '[.]' <<< "$( box::emptyRow "${w}" )"
  done
  jq -R '[.]' <<< "$( box::bottomRow "${w}" )"
}

while :; do
  screen="$(jq -s 'add' < <(renderPage) )"
  echo "${screen}" > thing.json
  send
  _key=$(readKey)
  case $_key in
    'q') break ;;
    'TIMEOUT') checkTermSize ;;
    *) sendKey "${_key}";;
  esac
  readFromBackend "${backendReadFd}"

done
