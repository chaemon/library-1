#{{{ bellman-ford shortest path
proc bellman_ford[T](g:Graph[T], s:int): (bool,seq[T],seq[int]) =
  let n = g.len
  var
    dist = newSeqWith(n,T.infty)
    prev = newSeqWith(n,-2)
    negative_cycle = false
  dist[s] = 0
  for k in 0..<n:
    for u in 0..<n:
      if dist[u] == T.infty: continue
      for e in g[u]:
        let t = dist[e.src] + e.weight
        if dist[e.dst] > t:
          dist[e.dst] = t
          prev[e.dst] = e.src
          if k == n-1:
            dist[e.dst] = -T.infty
            negative_cycle = true
  if negative_cycle:
    for k in 0..<n:
      for u in 0..<n:
        if dist[u] != -T.infty: continue
        for e in g[u]:
          dist[e.dst] = -T.infty
  return (not negative_cycle, dist, prev)
#}}}
