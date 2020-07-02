# verify-helper: PROBLEM https://judge.yosupo.jp/problem/convolution_mod_1000000007

const Mod = 1000000007
include "template/template.nim"
include "math/mod_int.nim"
include "math/fast_fourier_transform.nim"
include "math/arbitrary_mod_convolution.nim"

block main:
  let N, M = nextInt()
  var
    a = newSeqWith(N, Mint(nextInt()))
    b = newSeqWith(M, Mint(nextInt()))
  var amc = initArbitraryModConvolution[Mint]()
  let c = amc.multiply(a, b)
  echo c[0..<N+M-1].mapIt($it).join(" ")
