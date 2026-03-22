# returns the changed coordinates of two buffers
def compareBuffers:
 . as { $next, $prev } |
  if (  $prev != null and $prev.w == $next.w and $prev.h == $next.h ) then
    $next.screen | [paths(type == "string")] |
    map( select( ($next.screen[.[0]]) != ($prev.screen[.[0]])) | "\( tputCup(.[0]; 0) )\( $next.screen[.[0]] )" )
  else
    $next.screen | [paths(type == "string")] | map( "\( tputCup(.[0]; 0) )\( $next.screen[.[0]] )" )
  end;



#.next.i % 60 != 0 and
