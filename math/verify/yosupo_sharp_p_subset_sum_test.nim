# verify-helper: PROBLEM https://judge.yosupo.jp/problem/sharp_p_subset_sum

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/number_theoretic_transform_friendly_mod_int.nim"
include "math/formal_power_series.nim"

proc main():void =
  var ntt = initNumberTheoreticTransform[Mint]()
  let N, T = nextInt()
  var ct = newSeq[int](T + 1)
  for i in 0..<N: ct[nextInt()].inc
  var p = initFormalPowerSeries[Mint](T + 1)
  for A in 1..T:
    var sgn = 1
    for j in 1..T:
      let jA = j * A
      if jA > T: break
      p.data[jA] += Mint(ct[A]) / j * sgn
      sgn = -sgn
  p.setFFT(ntt)
  let q = p.exp()
  echo q.data[1..T].map(`$`).join(" ")

main()
