# returns the changed coordinates of two buffers
def compareBuffers:
  .nextScreen=(.next|screen) |
  if .prev != null then
    .prevScreen=(.prev|screen) |
    . as { $nextScreen, $prevScreen } |
   $nextScreen | [paths(type == "string")] |
     map( select(($nextScreen[.[0]][.[1]]) != ($prevScreen[.[0]][.[1]])) | { l: .[0], c: .[1], char: $nextScreen[.[0]][.[1]] } ) | printDiff
  else
    .nextScreen | print
  end;



