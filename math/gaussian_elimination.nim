# Gausian elimination {{{
proc gaussianElimination[T](A:Matrix[T]):(Matrix[T], seq[int]) =
  let
    (n, m) = (A.height, A.width)
    isZero = A.getIsZero()
  var
    A = A
    ids = newSeq[int]()
    j = 0
  for i in 0..<n:
    while j < m:
      var pivot = -1
      for ii in i..<n:
        if not isZero(A[ii][j]):
          pivot = ii
          break
      if pivot != -1:
        swap(A[i], A[pivot])
        break
      j.inc
    if j == m: break
    let d = T(1) / A[i][j]
    for jj in j..<m: A[i][jj] *= d
    for ii in 0..<n:
      if ii == i: continue
      let d = A[ii][j]
      for jj in j..<m: A[ii][jj] -= A[i][jj] * d
    ids.add(j)
    j.inc
  return (A, ids)

import options

proc linearEquations[T](A:Matrix[T], b:Vector[T]):Option[(Vector[T], seq[Vector[T]])] =
  let (n, m) = (A.height, A.width)
  assert n == b.len
  var A = A
  for i in 0..<n: A[i].add(b[i])
  let (B, ids) = A.gaussianElimination()
  if ids.len > 0 and ids[^1] == m:
    return none[(Vector[T], seq[Vector[T]])]()
  var
    s = ids.toSet()
    id = newSeq[int](m)
    ct = 0
    v = newSeq[Vector[T]]()
    x = initVector[T](m)
  for j in 0..<m:
    if j notin s:
      id[j] = ct
      ct.inc
      var v0 = initVector[T](m)
      v0[j] = T(1)
      v.add(v0)
  for i,ip in ids:
    x[ip] = B[i][^1]
    for j in 0..<m:
      if j in s: continue
      v[id[j]][ip] -= B[i][j]
  return (x, v).some
# }}}
