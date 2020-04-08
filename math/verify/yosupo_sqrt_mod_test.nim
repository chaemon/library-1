# verify-helper: PROBLEM https://judge.yosupo.jp/problem/sqrt_mod

include "template/template.nim"

include "math/mod_pow.nim"
include "math/mod_sqrt.nim"

block main:
  let T = nextInt()
  for i in 0..<T:
    let Y, P = nextInt()
    var r = modSqrt(Y, P)
    if r == -1: echo r
    else: echo min(r, P - r)
