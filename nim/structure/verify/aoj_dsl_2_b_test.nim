#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DSL_2_B"

include "../../template/template.nim"

include "../binary_indexed_tree.nim"

proc main() =
  let N, Q = nextInt()
  var bit = initBinaryIndexedTree[int](N)
  for i in 0..<Q:
    let T, X, Y = nextInt()
    if T == 0: bit.add(X - 1, Y)
    else: echo bit.sum(Y - 1) - bit.sum(X - 2)

main()
