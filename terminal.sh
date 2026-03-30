
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

terminal::white() {
  tput setaf 7
#  echo -e ""\033]00m\]   # white

}

terminal::grey() {
  echo -e "\\033[38;5;240m"
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

terminal::resetAll() {
  tput sgr0
}

terminal::raw() {
  stty raw -echo
}

terminal::sane() {
  stty sane
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
#txtblk='\e[0;30m' # Black - Regular
#txtred='\e[0;31m' # Red
#txtgrn='\e[0;32m' # Green
#txtylw='\e[0;33m' # Yellow
#txtblu='\e[0;34m' # Blue
#txtpur='\e[0;35m' # Purple
#txtcyn='\e[0;36m' # Cyan
#txtwht='\e[0;37m' # White
#bldblk='\e[1;30m' # Black - Bold
#bldred='\e[1;31m' # Red
#bldgrn='\e[1;32m' # Green
#bldylw='\e[1;33m' # Yellow
#bldblu='\e[1;34m' # Blue
#bldpur='\e[1;35m' # Purple
#bldcyn='\e[1;36m' # Cyan
#bldwht='\e[1;37m' # White
#unkblk='\e[4;30m' # Black - Underline
#undred='\e[4;31m' # Red
#undgrn='\e[4;32m' # Green
#undylw='\e[4;33m' # Yellow
#undblu='\e[4;34m' # Blue
#undpur='\e[4;35m' # Purple
#undcyn='\e[4;36m' # Cyan
#undwht='\e[4;37m' # White
#echo -e "\\033[38;5;240m"

#bakblk='\e[40m'   # Black - Background
#bakred='\e[41m'   # Red
#bakgrn='\e[42m'   # Green
#bakylw='\e[43m'   # Yellow
#bakblu='\e[44m'   # Blue
#bakpur='\e[45m'   # Purple
#bakcyn='\e[46m'   # Cyan
#bakwht='\e[47m'   # White
#txtrst='\e[0m'    # Text Reset