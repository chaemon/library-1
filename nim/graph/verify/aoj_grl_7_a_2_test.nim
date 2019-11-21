#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_7_A"

include "../../template/template.nim"
include "../template.nim"

include "../hopcroft_karp.nim"


proc main() =
  let X, Y, E = nextInt()
  var bm = initHopcroftKarp(X, Y)
  for i in 0..<E:
    let a, b = nextInt()
    bm.addEdge(a, b)
  echo bm.bipartiteMatching()

main()
