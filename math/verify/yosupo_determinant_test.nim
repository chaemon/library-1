# verify-helper: PROBLEM https://judge.yosupo.jp/problem/matrix_det

include "template/template.nim"

const Mod = 998244353

include "math/mod_int.nim"
include "math/matrix.nim"

block main:
  let N = nextInt()
  let a = newSeqWith(N, newSeqWith(N, nextInt()))
  let A = initMatrix[Mint](a)
  echo A.determinant