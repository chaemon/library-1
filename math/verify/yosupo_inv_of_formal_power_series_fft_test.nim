# verify-helper: PROBLEM https://judge.yosupo.jp/problem/inv_of_formal_power_series

const Mod = 998244353
const USE_FFT = false

include "template/template.nim"
include "math/mod_int.nim"
include "math/fast_fourier_transform_long_double.nim"
include "math/arbitrary_mod_convolution.nim"
include "math/formal_power_series.nim"

proc main():void =
  let N = nextInt()
  var p = initFormalPowerSeries[Mint](N)
  for i in 0..<N:
    p[i] = Mint(nextInt())
  let q = p.inv()
  echo q.map(`$`).join(" ")

main()
