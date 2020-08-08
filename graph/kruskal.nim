proc kruskal[T](g:Graph[T]):(T, seq[Edge[T]]) =
  var es = newSeq[Edge[T]]()
  for u in 0..<g.len:
    for e in g[u]:
      es.add(e)
  es.sort()
  var
    ret = newSeq[Edge[T]]()
    uf = initUnionFind(g.len)
    total = T(0)
  for e in es:
    if uf.union(e.src, e.dst):
      total += e.weight
      ret.add(e)
  return (total, ret)
