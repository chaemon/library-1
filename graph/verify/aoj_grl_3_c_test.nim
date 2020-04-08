# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_3_C

include "template/template.nim"
include "graph/template.nim"

include "graph/strongly_connected_components.nim"

proc main() =
  let V, E = nextInt()
  var g = initGraph[int](V)
  for i in 0..<E:
    let a,b = nextInt()
    g.addEdge(a,b)
  let (scc, buf) = StronglyConnectedComponents(g)
  let Q = nextInt()
  for i in 0..<Q:
    let a,b = nextInt()
    echo if scc[a] == scc[b]: 1 else: 0

main()
