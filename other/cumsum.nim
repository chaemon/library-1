#{{{ cumsum[T](v: seq[T])
proc cumsum[T](v:seq[T]):seq[T] =
  result = newSeq[T]()
  result.add(T(0))
  for a in v: result.add(result[^1] + a)
#}}}
