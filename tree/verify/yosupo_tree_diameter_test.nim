# verify-helper: PROBLEM https://judge.yosupo.jp/problem/tree_diameter

include "template/template.nim"
include "graph/template.nim"

include "tree/tree_diameter.nim"

proc main() =
  let N = nextInt()
  var g = initGraph[int](N)
  for i in 1..<N:
    let x, y, z = nextInt()
    g.addBiEdge(x,y,z)
  let (d, a) = g.treeDiameter()
  echo d, " ", a.len
  echo a.mapIt($it).join(" ")

main()
