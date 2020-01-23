# tree dfs {{{
type TreeDFS[T] = object
  depth, parent, size, dist:seq[int]

proc initTreeDFS[T](g:Graph[T], r = 0):TreeDFS[T] =
  var depth = newSeqWith(g.len, 0)
  var parent = newSeqWith(g.len, 0)
  var size = newSeqWith(g.len, 0)
  var dist = newSeqWith(g.len, 0)

  proc dfs(idx, par, dep, d:int) =
    depth[idx] = d
    parent[idx] = par
    dist[idx] = d
    for e in g[idx]:
      if e.dst != par:
        dfs(e.dst, idx, dep + 1, d + e.weight)
        size[idx] += size[e.dst]
  dfs(r, -1, 0, 0)

  return TreeDFS[T](depth:depth, parent:parent, size:size, dist:dist)
# }}}
