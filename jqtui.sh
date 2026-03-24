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
  log "Calling send"
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
  log "reading from backend"
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
   box::topRow "${w}" "$(date)"
  for x in $(seq 0 $(( firstMenuItemCount - 1 )) ); do
    highlight="false"
    if [[ "${x}" == "${cursor}" ]]; then
      highlight="true"
    fi
     box::optionRow "${w}" "${firstMenuItemNames[x]}" "${highlight}" "false"
  done
  for x in $(seq $(( firstMenuItemCount - 1 )) $(( h - 4 )) ); do
    box::emptyRow "${w}"
  done
  box::bottomRow "${w}"
  log "Ending render"
}

doRender() {
  log "doRender"
  screen="$(jq -Rn '[inputs]' <(renderFirstMenu))"
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
done



trap 'stty "$OLD_STTY_CFG"' EXIT

reset