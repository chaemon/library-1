# depth first search {{{
proc dfs(u:int, p = -1) =
  size[u] = 1
  for e in g[u]:
    if e.dst == p: continue
    dfs(e.dst, u)
    size[u] += size[e.dst]
#}}}
