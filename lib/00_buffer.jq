# splits a screen up into a buffer object
def buffer:
  . as { $w, $h, $screen } | $screen | map(./"") ;
