# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_7_A

include "template/template.nim"
include "graph/template.nim"

include "graph/bipartite_matching.nim"

proc main() =
  let X, Y, E = nextInt()
  var bm = initBipartiteMatching(X, Y)
  for i in 0..<E:
    let a, b = nextInt()
    bm.add_edge(a, b)
  echo bm.bipartiteMatching().len

main()
