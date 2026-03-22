# draws a screen of a given width height
def buffer:
  . as { $w, $h, $contents } | $contents | split("\n") | map(./"") ;
