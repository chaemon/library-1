# verify-helper: PROBLEM https://judge.yosupo.jp/problem/polynomial_interpolation

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/number_theoretic_transform_friendly_mod_int.nim"
include "math/formal_power_series.nim"
include "math/multipoint_evaluation.nim"
include "math/polynomial_interpolation.nim"

block main:
  var ntt = initNumberTheoreticTransform[Mint]()
  let N = nextInt()
  var
    x = initFormalPowerSeries[Mint](newSeqWith(N, Mint(nextInt())))
    y = newSeqWith(N, Mint(nextInt()))
  x.setFFT(ntt)
  x.setMult(ntt)
  var q = polynomialInterpolation(x, y)
  echo q
