# verify-helper: PROBLEM https://judge.yosupo.jp/problem/polynomial_interpolation

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/number_theoretic_transform.nim"
include "math/formal_power_series.nim"
include "math/multipoint_evaluation.nim"
include "math/polynomial_interpolation.nim"

block main:
  let N = nextInt()
  var
    x = initFormalPowerSeries[Mint](newSeqWith(N, Mint(nextInt())))
    y = newSeqWith(N, Mint(nextInt()))
  var q = polynomialInterpolation(x, y)
  echo q
