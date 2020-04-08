type DoublingLowestCommonAncestor[T] = object
  LOG:int
  dep:seq[int]
  table:seq[seq[int]]

proc initDoublingLowestCommonAncestor[T](g:Graph[T], r = 0):DoublingLowestCommonAncestor[T] =
  var
    LOG = 0
    t = 1
  while t <= g.len: t *= 2;LOG+=1
  var
    dep = newSeqWith(g.len,0)
    table = newSeqWith(LOG, newSeqWith(g.len, -1))

  proc dfs(idx, par, d:int) =
    table[0][idx] = par
    dep[idx] = d
    for e in g[idx]:
      if e.dst != par: dfs(e.dst, idx, d + 1)

  dfs(r, -1, 0)
  for k in 0..<LOG-1:
    for i in 0..<table[k].len:
      if table[k][i] == -1: table[k + 1][i] = -1
      else: table[k + 1][i] = table[k][table[k][i]]

  return DoublingLowestCommonAncestor[T](LOG:LOG, dep:dep, table:table)

proc query[T](self: DoublingLowestCommonAncestor[T], u,v:int):int =
  var (u,v) = (u,v)
  if self.dep[u] > self.dep[v]: swap(u,v)
  for i in countdown(self.LOG-1, 0):
    if (((self.dep[v] - self.dep[u]) shr i) and 1) > 0: v = self.table[i][v]
  if u == v: return u
  for i in countdown(self.LOG-1, 0):
    if self.table[i][u] != self.table[i][v]:
      u = self.table[i][u]
      v = self.table[i][v]
  return self.table[0][u]
