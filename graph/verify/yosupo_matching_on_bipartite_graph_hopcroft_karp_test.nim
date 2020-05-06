# verify-helper: PROBLEM https://judge.yosupo.jp/problem/bipartitematching

include "template/template.nim"
include "graph/template.nim"

include "graph/hopcroft_karp.nim"

proc main() =
  let L, R, M = nextInt()
  var g = initHopcroftKarp(L, R)
  for i in 0..<M:
    let u, v = nextInt()
    g.addEdge(u, v)
  
  let p = g.bipartiteMatching()
  echo p.len
  for p in p:
    echo p[0], " ", p[1]

main()
