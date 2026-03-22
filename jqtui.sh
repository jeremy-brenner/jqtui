#!/usr/bin/env bash

source terminal.sh
source box.sh
source style.sh

./build.sh
sleep 0.5

terminal::hijackTerm
w="$(terminal::getWidth)"
h="$(terminal::getHeight)"
i=0
style="basic"
prev='null'

coproc backendProc {
  jq --unbuffered -r --slurpfile styles style.json -L ./out 'include "jqtui"; compareBuffers'
}

exec 10<&"${backendProc[0]}"
exec 11>&"${backendProc[1]}"

backendReadFd=10
backendWriteFd=11

log() {
  echo "${1}" >> frontend.log
}

package() {
  jq -nc --argjson i "${i}" --argjson w "${w}" --argjson h "${h}" --arg style "${style}" --arg contents "${contents}" '{ $i, $w, $h, $style, $contents }'
  ((i++))
}

send() {
  echo "s1" >> log.txt
  local _next="$(package)"
    echo "s2" >> log.txt
  jq -nc --argjson prev "${prev}" --argjson next "${_next}" '{ $prev, $next }' > debug.json
  jq -nc --argjson prev "${prev}" --argjson next "${_next}" '{ $prev, $next }' >&${backendWriteFd}
    echo "s3" >> log.txt

  prev="${_next}"
}

sendKey() {
  _key="${1}"
  if [[ -n "${_key}" ]]; then
    echo "" >/dev/null
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
  box::topRow "${w}" "Pretty Cool"
  for x in $(seq 0 $(( itemCount - 1 )) ); do
    box::optionRow "${w}" "${itemNames[x]}" "false" "false"
  done
  for x in $(seq $(( itemCount - 1 )) $(( h - 4 )) ); do
    box::emptyRow "${w}"
  done
  box::bottomRow "${w}"
}

while :; do
  contents="$(renderPage)"
  send
  _key=$(readKey)
  case $_key in
    'q') break ;;
    'TIMEOUT') checkTermSize ;;
    *) sendKey "${_key}";;
  esac
  readFromBackend "${backendReadFd}"

done
