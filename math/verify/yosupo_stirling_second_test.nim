# verify-helper: PROBLEM https://judge.yosupo.jp/problem/stirling_number_of_the_second_kind

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/number_theoretic_transform_friendly_mod_int.nim"
include "math/formal_power_series.nim"
include "math/formal_power_series_seq.nim"

block main:
  var ntt = initNumberTheoreticTransform[Mint]()
  let N = nextInt()
  var p = initFormalPowerSeries[Mint](N)
  p.setFFT(ntt)
  p.setMult(ntt)
  echo stirlingSecond[Mint](N)
