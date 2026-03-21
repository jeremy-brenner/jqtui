
terminal::restoreTerm() {
  stty echo
  tput rmcup
  tput cnorm
}

terminal::hijackTerm() {
  trap terminal::restoreTerm EXIT
  stty -echo
  tput smcup
  tput civis
#  tput clear
  tput cup 0 0
}

terminal::getWidth() {
  tput cols
}

terminal::getHeight() {
  tput lines
}