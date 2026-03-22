# returns the changed coordinates of two buffers
def compareBuffers:
  .nextBuffer=(.next|buffer) |
  if .prev != null then
    .prevBuffer=(.prev|buffer) |
    . as { $nextBuffer, $prevBuffer } |
    $nextBuffer | [paths(type == "string")] |
      map( select(($nextBuffer[.[0]][.[1]]) != ($prevBuffer[.[0]][.[1]])) | { l: .[0], c: .[1], char: $nextBuffer[.[0]][.[1]] } ) | printDiff
  else
    .next | buffer | print
  end;



