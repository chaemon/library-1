# verify-helper: PROBLEM https://judge.yosupo.jp/problem/discrete_logarithm_mod
include "template/template.nim"

include "math/mod_log.nim"

block main:
  let T = nextInt()
  for i in 0..<T:
    let X, Y, M = nextInt()
    echo modLog(X, Y, M)
