# verify-helper: PROBLEM https://judge.yosupo.jp/problem/exp_of_formal_power_series

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/number_theoretic_transform_friendly_mod_int.nim"
include "math/formal_power_series.nim"

proc main():void =
  var ntt = initNumberTheoreticTransform()
  let N = nextInt()
  var p = initFormalPowerSeries[Mint](N)
  p.setFFT(
    proc(a:var FormalPowerSeries[Mint]) = ntt.ntt(a.data),
    proc(a:var FormalPowerSeries[Mint]) = ntt.intt(a.data))
  for i in 0..<N:
    p.data[i] = Mint().init(nextInt())
  let q = p.exp()
  echo q.data.map(`$`).join(" ")

main()
