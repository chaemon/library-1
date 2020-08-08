# verify-helper: PROBLEM https://judge.yosupo.jp/problem/factorize

include "template/template.nim"
include "math/factorization.nim"

block main:
  let Q = nextInt()
  for _ in 0..<Q:
    let x = factor(nextInt()).sorted()
    stdout.write(x.len, " ")
    stdout.write(x.mapIt($it).join(" "))
    echo ""
