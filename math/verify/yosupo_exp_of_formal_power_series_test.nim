# verify-helper: PROBLEM https://judge.yosupo.jp/problem/exp_of_formal_power_series

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/number_theoretic_transform_friendly_mod_int.nim"
include "math/formal_power_series.nim"

proc main():void =
  var ntt = initNumberTheoreticTransform[Mint]()
  let N = nextInt()
  var p = initFormalPowerSeries[Mint](N)
  p.setFFT(ntt)
  for i in 0..<N:
    p[i] = Mint(nextInt())
  let q = p.exp()
  echo q.map(`$`).join(" ")

main()
