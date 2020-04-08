# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_6_B

include "template/template.nim"
include "graph/template.nim"

include "graph/primal_dual.nim"

proc main() =
  let V, E, F = nextInt()
  var g = initPrimalDual[int,int](V)
  for i in 0..<E:
    let a, b, c, d = nextInt()
    g.add_edge(a, b, c, d)
  echo g.minCostFlow(0, V - 1, F)

main()
