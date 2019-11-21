#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_1_B"

include "../../template/template.nim"
include "../template.nim"

include "../bellman_ford.nim"

proc main() =
  var
    V, E, R = nextInt()
  var g = initGraph[int](V)
  for i in 0..<E:
    var a, b, c = nextInt()
    g.addEdge(a,b,c)
  let (r,dists,_) = bellman_ford(g, R);
  if not r: echo "NEGATIVE CYCLE"
  else:
    for dist in dists:
      if dist == int.infty: echo "INF"
      else: echo dist

main()
