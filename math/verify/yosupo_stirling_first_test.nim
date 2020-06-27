# verify-helper: PROBLEM https://judge.yosupo.jp/problem/stirling_number_of_the_first_kind

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
  var s = stirlingFirst[Mint](N)
  var i = 0
  for d in s.data.mitems:
    if (N - i) mod 2 == 1:
      d *= -1
    i.inc
  echo s
