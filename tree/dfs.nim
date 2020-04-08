# depth first search {{{
proc dfs[T](g:Graph[T], u:int, p = -1) =
  for e in g[u]:
    if e.dst == p: continue
    g.dfs(e.dst, u)
#}}}
