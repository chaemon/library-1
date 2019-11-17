proc treeDiameter[T](g:Graph[T]):int =
  proc dfs(idx, par:int):(T,int) =
    result[1] = idx
    for e in g[idx]:
      if e.dst == par: continue
      var cost = dfs(e.dst, idx)
      cost[0] += e.weight
      result = max(result, cost)
  let
    p = dfs(0, -1)
    q = dfs(p[1], -1)
  return q[0]
