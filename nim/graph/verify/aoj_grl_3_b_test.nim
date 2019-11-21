#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_3_B"

include "../../template/template.nim"
include "../template.nim"

include "../lowlink.nim"

proc main() =
  let V, E = nextInt()
  var g = initGraph[int](V)
  for i in 0..<E:
    let x,y = nextInt()
    g.addBiEdge(x,y)
  var lowlink = LowLink(g)
  lowlink.bridge.sort()
  for p in lowlink.bridge: echo p[0], " ", p[1]

main()
