# binomialTable(N:int) {{{
proc binomialTable(N:int):seq[seq[int]] =
  result = newSeqWith(N+1, newSeq[int]())
  for i in 0..N:
    result[i] = newSeqWith(i + 1, 0)
    for j in 0..i:
      if j == 0 or j == i: result[i][j] = 1
      else: result[i][j] = result[i - 1][j - 1] + result[i - 1][j]
# }}}
