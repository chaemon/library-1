# verify-helper: PROBLEM https://judge.yosupo.jp/problem/pow_of_formal_power_series

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/number_theoretic_transform.nim"
include "math/formal_power_series.nim"

proc main():void =
  let N, M = nextInt()
  var p = initFormalPowerSeries[Mint](N)
  for i in 0..<N: p[i] = Mint(nextInt())
  echo p.pow(M)

main()
