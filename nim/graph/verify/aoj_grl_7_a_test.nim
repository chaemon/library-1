#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_7_A"

include "../../template/template.nim"
include "../template.nim"

include "../bipartite_matching.nim"

proc main() =
  let X, Y, E = nextInt()
  var bm = newBipartiteMatching(X + Y)
  for i in 0..<E:
    let a, b = nextInt()
    bm.add_edge(a, X + b);
  echo bm.bipartiteMatching()

main()
