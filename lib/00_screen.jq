# draws a screen of a given width height
def screen:
  . as { $w, $h, $contents } | .screen = ([range($h)] | map( . as $x | [range($w) | . as $y | ( try ($contents[$x]/"")[$y] // "\u00a0" ) ]) ) | .screen;
