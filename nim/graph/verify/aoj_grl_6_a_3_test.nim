#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_6_A"

include "../../template/template.nim"
include "../template.nim"

include "../push_relabel.nim"

proc main() =
  let V,E = nextInt()
  var g = initPushRelabel[int](V)
  for i in 0..<E:
    let a,b,c = nextInt()
    g.addEdge(a, b, c)
  echo g.maxFlow(0, V - 1)

main()
