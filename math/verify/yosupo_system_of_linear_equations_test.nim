# verify-helper: PROBLEM https://judge.yosupo.jp/problem/system_of_linear_equations

const Mod = 998244353

include "template/template.nim"
include "math/mod_int.nim"
include "math/matrix.nim"
include "math/gaussian_elimination.nim"

block main:
  let N, M = nextInt()
  let
    A:Matrix[Mint] = newSeqWith(N, newSeqWith(M, Mint(nextInt())))
    b:Vector[Mint] = newSeqWith(N, Mint(nextInt()))
  let t = linearEquations(A, b)
  if t.isSome():
    let (x, vs) = t.get
    echo vs.len
    echo x.mapIt($it).join(" ")
    for v in vs:
      echo v.mapIt($it).join(" ")
  else:
    echo -1
