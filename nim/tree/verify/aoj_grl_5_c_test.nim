#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_5_C"

include "../../template/template.nim"
include "../../graph/template.nim"

include "../doubling_lowest_common_ancestor.nim"

proc main() =
  let N = nextInt()
  var g = newGraph[int](N)
  for i in 0..<N:
    let k = nextInt()
    for j in 0..<k:
      let c = nextInt()
      g.addBiEdge(i,c)
  let lca = newDoublingLowestCommonAncestor(g, 0)
  let Q = nextInt()
  for i in 0..<Q:
    let x, y = nextInt()
    echo lca.query(x, y)

main()
