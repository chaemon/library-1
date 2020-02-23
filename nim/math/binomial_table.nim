# binomialTable(N:int) {{{
proc binomialTable(N:int):seq[seq[int]] =
  result = newSeqWith(N+1, newSeqWith(N+1, 0))
  for i in 0..N:
    for j in 0..i:
      if j == 0 or j == i: result[i][j] = 1
      else: result[i][j] = result[i - 1][j - 1] + result[i - 1][j]
# }}}
