# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DSL_1_B

include "template/template.nim"

include "structure/weighted_union_find.nim"

proc main() =
  let N, M = nextInt()
  var tree = initWeightedUnionFind[int](N)
  for i in 0..<M:
    let A, B, C = nextInt()
    if A == 0:
      let D = nextInt()
      tree.unionSet(B, C, D)
    else:
      if tree.root(B) == tree.root(C):
        echo tree.diff(B, C)
      else:
        echo "?"

main()
