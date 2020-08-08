# verify-helper: PROBLEM https://judge.yosupo.jp/problem/persistent_unionfind

include "template/template.nim"

include "structure/persistent_array.nim"
include "structure/persistent_union_find.nim"

proc main() =
  let N, Q = nextInt()
  var
    uf = initPersistentUnionFind(N)
    G = newSeq[PersistentUnionFind](Q+1)
  G[0] = uf
  
  for i in 0..<Q:
    var t, k, u, v = nextInt()
    k.inc
    if t == 0:
      G[i+1] = G[k].union(u, v)
    else:
      echo if G[k].find(u) == G[k].find(v): 1 else: 0

main()
