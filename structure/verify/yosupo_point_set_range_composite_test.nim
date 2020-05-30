# verify-helper: PROBLEM https://judge.yosupo.jp/problem/point_set_range_composite

include "template/template.nim"

include "structure/segment_tree.nim"

const Mod = 998244353

include "math/mod_int.nim"

proc main() =
  let N, Q = nextInt()
  var v = newSeq[(Mint,Mint)]()
  for i in 0..<N:
    v.add((nextInt().Mint, nextInt().Mint))
  var st = initSegmentTree[(Mint,Mint)](N, (a:(Mint, Mint), b:(Mint, Mint)) => (a[0] * b[0], b[0] * a[1] + b[1]), (1.Mint, 0.Mint))
  st.build(v)
  for _ in 0..<Q:
    let q = nextInt()
    if q == 0:
      let p, c, d = nextInt()
      st[p] = (c.Mint, d.Mint)
    elif q == 1:
      let l, r, x = nextInt()
      let a = st[l..<r]
      echo a[0] * x.Mint + a[1]
    else:
      doAssert(false)

main()
