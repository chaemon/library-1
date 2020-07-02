# verify-helper: PROBLEM https://judge.yosupo.jp/problem/scc

include "template/template.nim"
include "graph/template.nim"

include "graph/strongly_connected_components.nim"
include "graph/topological_sort.nim"

proc main() =
  let N, M = nextInt()
  var g = initGraph[int](N)
  for i in 0..<M:
    let a, b = nextInt()
    g.addEdge(a, b)
  let (a, t) = g.stronglyConnectedComponents()
  let K = t.len
  var comp = newSeq[seq[int]](K)
  for i,a in a:
    comp[a].add(i)
  let s = t.topologicalSort()
  echo K
  for i in s:
    stdout.write comp[i].len, " "
    echo comp[i].mapIt($it).join(" ")

main()
