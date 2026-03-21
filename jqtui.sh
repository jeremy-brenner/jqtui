#!/usr/bin/env bash

source terminal.sh

./build.sh
sleep 0.5

terminal::hijackTerm

coproc backendProc {
  jq  --unbuffered -r --slurpfile styles style.json -L ./out 'include "jqtui"; compareBuffers'
}

exec 10<&"${backendProc[0]}"
exec 11>&"${backendProc[1]}"

backendReadFd=10
backendWriteFd=11

log() {
  echo "${1}" >> frontend.log
}

w=0
h=0
i=0
style="basic"
contents='[]'
prev='null'

package() {
  jq -nc --argjson i "${i}" --argjson w "${w}" --argjson h "${h}" --arg style "${style}" --argjson contents "${contents}" '{ $i, $w, $h, $style, $contents }'
  ((i++))
}

send() {
  local _next="$(package)"
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
  IFS= read -t 0.01 -rsn1 -d '' mode < /dev/tty
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
  backendReadFd="${1}"
  read -t 0.01 -d '' -r -u "${backendReadFd}" results
  if [[ -n "${results}" ]]; then
    printf -- '%s' "${results}"
  fi
}

log "startup"

checkTermSize() {
  newW="$(terminal::getWidth)"
  newH="$(terminal::getHeight)"
  if [[ -z "${newW}" ]] || [[ -z "${newH}" ]]; then
    return
  fi
  if [[ "${newW}" != "${w}" ]] || [[ "${newH}" != "${h}" ]]; then
    w="${newW}"
    h="${newH}"
    send
  fi
}

while true; do
  _key=$(readKey)
  case $_key in
    'q') break ;;
    'TIMEOUT') checkTermSize ;;
    *) sendKey "${_key}";;
  esac
  readFromBackend "${backendReadFd}"
done
