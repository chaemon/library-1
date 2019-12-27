#define PROBLEM "https://judge.yosupo.jp/problem/sqrt_of_formal_power_series"

const Mod = 998244353

include "../../template/template.nim"
include "../mod_int.nim"
include "../mod_pow.nim"
include "../mod_sqrt.nim"
include "../number_theoretic_transform_friendly_mod_int.nim"
include "../formal_power_series.nim"

block main:
  var ntt = initNumberTheoreticTransform()
  let N = nextInt()
  var p = initFormalPowerSeries[Mint](N)
  p.setFFT(
    proc(a:var FormalPowerSeries[Mint]) = ntt.ntt(a.data),
    proc(a:var FormalPowerSeries[Mint]) = ntt.intt(a.data))
  p.setMult(proc(a, b:FormalPowerSeries[Mint]):FormalPowerSeries[Mint] = initFormalPowerSeries(ntt.multiply(a.data, b.data)))
  p.setSqrt(proc(a:Mint):Mint = Mint().init(modSqrt(int(a.v), Mod)))
  for i in 0..<N:
    p.data[i] = Mint().init(nextInt())
  var q = p.sqrt()
  if q.data.len == 0:
    echo -1
  else:
    var
      ans = q
      ans0 = -q
    for i in 0..<ans.data.len:
      if ans.data[i].v > ans0.data[i].v:
        swap(ans, ans0);break
      elif ans.data[i].v < ans0.data[i].v:
        break
    echo ans
