#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_2_A"

include "../../template/template.nim"
include "../template.nim"

include "../prim.nim"

proc main() =
  let
    V,E = nextInt()
  var
    g = newGraph[int](V)
  for i in 0..<E:
    let
      a,b,c = nextInt()
    g.addBiEdge(a,b,c)
  echo prim(g)[0]

main()
