#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_2_A"

include "../../template/template.nim"
include "../template.nim"

include "../../structure/union_find.nim"

include "../kruskal.nim"

proc main() =
  var
    V, E = nextInt()
    g = newGraph[int](V)
  for i in 0..<E:
    let a, b, c = nextInt()
    g.addBiEdge(a,b,c)
  echo kruskal(g)[0]

main()
