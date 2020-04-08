# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_2_B

include "template/template.nim"
include "graph/template.nim"

include "structure/union_find.nim"
include "structure/skew_heap.nim"

include "graph/chu_liu_edmond.nim"

proc main() =
  var
    V, E, R = nextInt()
    edges = newSeq[Edge[int]]()
  for i in 0..<E:
    let a, b, c = nextInt()
    edges.add(initEdge(a,b,c))
  var t = initMinimumSpanningTreeArborescence[int](edges, V)
  echo t.build(R)

main()
