#define PROBLEM "https://judge.yosupo.jp/problem/multipoint_evaluation"

const Mod = 998244353

include "../../template/template.nim"
include "../mod_int.nim"
include "../number_theoretic_transform_friendly_mod_int.nim"
include "../formal_power_series.nim"
include "../multipoint_evaluation.nim"

block main:
  var ntt = initNumberTheoreticTransform()
  let N, M = nextInt()
  var c = initFormalPowerSeries[Mint](N)
  var p = initFormalPowerSeries[Mint](M)
  p.setFFT(
    proc(a:var FormalPowerSeries[Mint]) = ntt.ntt(a.data),
    proc(a:var FormalPowerSeries[Mint]) = ntt.intt(a.data))
  p.setMult(proc(a, b:FormalPowerSeries[Mint]):FormalPowerSeries[Mint] = initFormalPowerSeries(ntt.multiply(a.data, b.data)))
  for i in 0..<N:
    c.data[i] = Mint().init(nextInt())
  for i in 0..<M:
    p.data[i] = Mint().init(nextInt())
  var q = multipointEvaluation(c, p)
  echo q
