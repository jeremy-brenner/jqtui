def tput(command):
  "\u001b[\( command )";

def tputCup(x; y):
  tput("\( x+1 );\( y+1 )H");

def tputInvert:
  tput("7m");

def tputReset:
  tput("0m");
