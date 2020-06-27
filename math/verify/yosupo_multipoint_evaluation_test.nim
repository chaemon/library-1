# verify-helper: PROBLEM https://judge.yosupo.jp/problem/multipoint_evaluation

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/number_theoretic_transform_friendly_mod_int.nim"
include "math/formal_power_series.nim"
include "math/multipoint_evaluation.nim"

block main:
  var ntt = initNumberTheoreticTransform[Mint]()
  let N, M = nextInt()
  var c = initFormalPowerSeries[Mint](N)
  var p = initFormalPowerSeries[Mint](M)
  p.setFFT(ntt)
  p.setMult(ntt)
  for i in 0..<N:
    c.data[i] = Mint(nextInt())
  for i in 0..<M:
    p.data[i] = Mint(nextInt())
  var q = multipointEvaluation(c, p)
  echo q
