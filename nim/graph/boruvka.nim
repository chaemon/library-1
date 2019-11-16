proc boruvka[T,F](N:int, f:F):T =
  var
    rev = newseq[int](N)
    belong = newSeq[int](N)
    uf = newUnionFind(N)
    ret = T(0)
  while uf.size(0) != N:
    var p = 0
    for i in 0..<N:
      if uf.root(i) == i:
        belong[i] = p
        p += 1
        rev[belong[i]] = i
    for i in 0..<N: belong[i] = belong[uf.root(i)]
    let v = f(p, belong)
    var update = false
    for i in 0..<p:
      if v[i][1] == 0 and uf.unionSet(rev[i], rev[v[i][1]]):
        ret += v[i][0]
        update = true
    if not update: return -1 # notice!!
  return ret;
