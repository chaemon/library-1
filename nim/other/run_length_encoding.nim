# runLengthEncoding[T](v:seq[T]) {{{
proc runLengthEncoding[T](v:seq[T]):seq[(T,int)] =
  result = newSeq[(T,int)]()
  var i = 0
  while i < v.len:
    var j = i
    while j < v.len and v[j] == v[i]: j.inc
    result.add((v[i], j - i))
    i = j
# }}}
