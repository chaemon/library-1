# verify-helper: PROBLEM https://judge.yosupo.jp/problem/lca

include "template/template.nim"
include "graph/template.nim"

include "tree/doubling_lowest_common_ancestor.nim"

proc main() =
  let N, Q = nextInt()
  var g = initGraph[int](N)
  for i in 1..<N:
    let p = nextInt()
    g.addBiEdge(i, p)
  let lca = initDoublingLowestCommonAncestor(g, 0)
  for i in 0..<Q:
    let x, y = nextInt()
    echo lca.query(x, y)


main()
