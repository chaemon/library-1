#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_3_A"

include "../../template/template.nim"
include "../template.nim"

include "../lowlink.nim"

proc main() =
  let V,E = nextInt()
  var g = newGraph[int](V)
  for i in 0..<E:
    var x,y = nextInt()
    g.addBiEdge(x,y)
  var lowlink = LowLink(g)
  lowlink.articulation.sort()
  for v in lowlink.articulation: echo v

main()
