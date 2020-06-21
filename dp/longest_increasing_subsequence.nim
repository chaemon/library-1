# longest common subsequence {{{
proc longestIncreasingSubsequence[T](a:seq[T], strict:bool):int =
  var lis = newSeq[T]()
  for p in a:
    var it: int
    if strict: it = lis.lowerBound(p)
    else: it = lis.upperBound(p)
    if it == lis.len: lis.add(p)
    else: lis[it] = p
  return lis.len
# }}}
