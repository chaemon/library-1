proc StronglyConnectedComponents(g:Graph[int]):(seq[int], Graph[int]) =
  var
    comp = newSeqWith(g.len, -1)
    used = newSeq[bool](g.len)
    order = newSeq[int]()
    gg = newGraph[int](g.len)
    rg = newGraph[int](g.len)
  for i in 0..<g.len:
    for e in g[i]:
      gg.addEdge(i,e.dst)
      rg.addEdge(e.dst,i)

  proc dfs(idx:int) =
    if used[idx]: return
    used[idx] = true
    for e in gg[idx]: dfs(e.dst)
    order.add(idx);

  proc rdfs(idx, cnt:int) =
    if comp[idx] != -1: return
    comp[idx] = cnt
    for e in rg[idx]: rdfs(e.dst, cnt)

  for i in 0..<gg.len: dfs(i)
  order.reverse()
  var p = 0
  for i in order:
    if comp[i] == -1: rdfs(i, p);p += 1

  var t = newGraph[int](p)
  for i in 0..<g.len:
    for e in g[i]:
      let
        x = comp[i]
        y = comp[e.dst]
      if x == y: continue
      t.addEdge(x,y)
  return (comp, t)
