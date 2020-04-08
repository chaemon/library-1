# verify-helper: PROBLEM https://judge.yosupo.jp/problem/log_of_formal_power_series

const Mod = 998244353

include "../../template/template.nim"
include "../mod_int.nim"
include "../number_theoretic_transform_friendly_mod_int.nim"
include "../formal_power_series.nim"

proc main():void =
  var ntt = initNumberTheoreticTransform()
  let N = nextInt()
  var p = initFormalPowerSeries[Mint](N)
  p.setFFT(
    proc(a:var FormalPowerSeries[Mint]) = ntt.ntt(a.data),
    proc(a:var FormalPowerSeries[Mint]) = ntt.intt(a.data))
  p.setMult(proc(a, b:FormalPowerSeries[Mint]):FormalPowerSeries[Mint] = initFormalPowerSeries(ntt.multiply(a.data, b.data)))
  for i in 0..<N:
    p.data[i] = Mint().init(nextInt())
  echo p.pow(100000)

main()
