proc getPartition[T](n,k:int):seq[seq[T]] =
  result = newSeqWith(n + 1, newSeq[T](k + 1))
  result[0][0] = T(1)
  for i in 0..n:
    for j in 1..k:
      if i - j >= 0: result[i][j] = result[i][j - 1] + result[i - j][j]
      else: result[i][j] = result[i][j - 1]
