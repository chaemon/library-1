#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DSL_1_A"

include "../../template/template.nim"

include "../union_find.nim"

proc main() =
  let N, Q = nextInt()
  var uf = newUnionFind(N)
  for i in 0..<Q:
    let t, x, y = nextInt()
    if t == 0: uf.unionSet(x, y)
    else: echo if uf.root(x) == uf.root(y): 1 else: 0

main()
