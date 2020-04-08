# verify-helper: PROBLEM https://judge.yosupo.jp/problem/bernoulli_number

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/number_theoretic_transform_friendly_mod_int.nim"
include "math/formal_power_series.nim"
include "math/formal_power_series_seq.nim"

block main:
  var ntt = initNumberTheoreticTransform()
  let N = nextInt()
  var p = initFormalPowerSeries[Mint](N)
  p.setFFT(
    proc(a:var FormalPowerSeries[Mint]) = ntt.ntt(a.data),
    proc(a:var FormalPowerSeries[Mint]) = ntt.intt(a.data))
  p.setMult(proc(a, b:FormalPowerSeries[Mint]):FormalPowerSeries[Mint] = initFormalPowerSeries(ntt.multiply(a.data, b.data)))
  echo bernoulli[Mint](N)
