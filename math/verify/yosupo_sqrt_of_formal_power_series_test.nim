# verify-helper: PROBLEM https://judge.yosupo.jp/problem/sqrt_of_formal_power_series

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/mod_pow.nim"
include "math/mod_sqrt.nim"
include "math/number_theoretic_transform.nim"
include "math/formal_power_series.nim"

block main:
  let N = nextInt()
  var p = initFormalPowerSeries[Mint](N)
  p.setSqrt(modSqrt[Mint])
  for i in 0..<N:
    p[i] = Mint(nextInt())
  var r = p.sqrt()
  if not r.isSome:
    echo -1
  else:
    echo r.get
