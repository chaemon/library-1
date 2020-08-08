# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DSL_1_A

include "template/template.nim"

include "structure/union_find.nim"

proc main() =
  let N, Q = nextInt()
  var uf = initUnionFind(N)
  for i in 0..<Q:
    let t, x, y = nextInt()
    if t == 0: uf.union(x, y)
    else: echo if uf.find(x) == uf.find(y): 1 else: 0

main()
