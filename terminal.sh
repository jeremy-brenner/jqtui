
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

terminal::invert() {
  tput rev
}

terminal::startUnderline() {
  tput smul
}

terminal::endUnderline() {
  tput rmul
}

terminal::bold() {
  tput bold
}

terminal::red() {
  tput setaf 1
}

terminal::green() {
  tput setaf 2
}

terminal::yellow() {
  tput setaf 3
}

terminal::blue() {
  tput setaf 4
}

terminal::purple() {
  tput setaf 5
}
terminal::teal() {
  tput setaf 6
}

terminal::white() {
  tput setaf 7
}

terminal::resetAll() {
  tput sgr0
}

terminal::test() {
echo "
regular bold underline
$(terminal::red)Text $(terminal::bold)Text $(terminal::resetAll)$(terminal::red)$(terminal::startUnderline)Text$(terminal::endUnderline)
$(terminal::red)Text $(terminal::bold)Text $(terminal::resetAll)$(terminal::red)$(terminal::startUnderline)Text$(terminal::endUnderline)
$(terminal::green)Text $(terminal::bold)Text $(terminal::resetAll)$(terminal::green)$(terminal::startUnderline)Text$(terminal::endUnderline)
$(terminal::yellow)Text $(terminal::bold)Text $(terminal::resetAll)$(terminal::yellow)$(terminal::startUnderline)Text$(terminal::endUnderline)
$(terminal::blue)Text $(terminal::bold)Text $(terminal::resetAll)$(terminal::blue)$(terminal::startUnderline)Text$(terminal::endUnderline)
$(terminal::purple)Text $(terminal::bold)Text $(terminal::resetAll)$(terminal::purple)$(terminal::startUnderline)Text$(terminal::endUnderline)
$(terminal::teal)Text $(terminal::bold)Text $(terminal::resetAll)$(terminal::teal)$(terminal::startUnderline)Text$(terminal::endUnderline)
"
}