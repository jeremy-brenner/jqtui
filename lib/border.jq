# draws a border
def border:
 { bs: . } | $styles[0]["barf"] as $style | .bs as { $h, $w }
 | .buf = ([range($h)] | map( [range($w) | "\u00a0"]))
 | .buf[0][0] = $style.topleft
 | .buf[0][1:-1] |= map($style.topmiddle)
 | .buf[0][-1] = $style.topright
 | .buf[-1][0] = $style.bottomleft
 | .buf[-1][1:-1] |= map($style.bottommiddle)
 | .buf[-1][-1] = $style.bottomright
 | .buf[1:-1] |= map(.[0]=$style.sidecol|.[-1]=$style.sidecol)
 | map(join(""))
 | join("\n")
  ;

#until(.bytes / pow(base; .exp) < base; .exp+=1) |
#.buf[1:-1] |= map(.[1:-1] |= map(  ) )
