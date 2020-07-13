# verify-helper: PROBLEM https://judge.yosupo.jp/problem/convolution_mod

const Mod = 998244353
include "template/template.nim"
include "standard_library/bitutils.nim"
include "math/number_theoretic_transform_raw.nim"

block main:
  let N, M = nextInt()
  var a, b = newSeq[int](max(N, M)+1)
  for i in 1..N: a[i] = nextInt()
  for i in 1..M: b[i] = nextInt()
  var ntt = initNumberTheoreticTransform()
  let c = ntt.multiply(a, b)
  for i in 2..N+M:
    stdout.write c[i]
    if i != N+M: stdout.write " "
  echo ""
