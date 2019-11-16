#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_1_A"

include "../../template/template.nim"
include "../template.nim"

include "../dijkstra.nim"

proc main() =
  var
    V = nextInt()
    E = nextInt()
    R = nextInt()
    g = newGraph[int](V)

  for i in 0..<E:
    var
      a = nextInt()
      b = nextInt()
      c = nextInt()
    g.addEdge(a, b, c)
  
  let dist = dijkstra(g, R)[0]
  for d in dist:
    if d == int.infty: echo "INF"
    else: echo d

main()
