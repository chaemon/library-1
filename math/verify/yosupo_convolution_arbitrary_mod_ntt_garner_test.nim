# verify-helper: PROBLEM https://judge.yosupo.jp/problem/convolution_mod_1000000007

const Mod = 1000000007
include "template/template.nim"
include "math/mod_int.nim"
include "math/number_theoretic_transform_friendly_mod_int.nim"
include "math/garner.nim"
include "math/arbitrary_mod_convolution_ntt.nim"

block main:
  let N, M = nextInt()
  var
    a = newSeqWith(N, nextInt())
    b = newSeqWith(M, nextInt())
  let s = initNumberTheoreticTransformArbitraryMod[Mint]()
  echo s.multiply(a, b).mapIt($it).join(" ")
