# verify-helper: PROBLEM https://judge.yosupo.jp/problem/sqrt_mod

include "template/template.nim"

include "math/mod_int.nim"
include "math/mod_sqrt.nim"

block main:
  let T = nextInt()
  for i in 0..<T:
    let Y = nextInt()
    DMint.setMod(nextInt())
    var r = modSqrt(DMint(Y))
    if r.isSome: echo r.get
    else: echo -1
