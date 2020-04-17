import sequtils

proc hungarian[T](a:Matrix[T]):(T, seq[int]) =
  let n = a.len
  var
    p, q:int
    fx = newSeqWith(n, T.inf)
    fy = newSeqWith(n, T(0))
    x = newSeqWith(n, -1)
    y = newSeqWith(n, -1)
  for i in 0..<n: fx[i] = a[i].min
  var i = 0
  while i < n:
    var
      t = newSeqWith(n, -1)
      s = newSeqWith(n+1, i)
    var (p, q) = (0, 0)
    while p <= q and x[i] < 0:
      assert(false)
      var (k, j) = (s[p], 0)
      while j < n and x[i] < 0:
        if fx[k] + fy[j] == a[k][j] and t[j] < 0:
          q.inc
          s[q] = y[j]
          t[j] = k
          if s[q] < 0:
            p = j
            while p >= 0:
              y[j] = t[j]
              k = t[j]
              p = x[k]
              x[k] = j
              j = p
        j.inc
      p.inc
    if x[i] < 0:
      var d = T.inf
      for k in 0..q:
        for j in 0..<n:
          if t[j] < 0: d = min(d, fx[s[k]] + fy[j] - a[s[k]][j])
      for j in 0..<n:
        fy[j] += (if t[j] < 0: 0 else: d)
      for k in 0..q: fx[s[k]] -= d
    else:
      i.inc
  var ret = 0
  for i in 0..<n: ret += a[i][x[i]]
  return (ret, x)
