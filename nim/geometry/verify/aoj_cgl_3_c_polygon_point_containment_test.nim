#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_3_C"

include "../../template/template.nim"
include "../template.nim"

block main:
  let
    g = nextInt()
    poly = newSeqWith(g, initPoint(nextFloat(), nextFloat()))
    q = nextInt()
  for i in 0..<q:
    let p = initPoint(nextFloat(), nextFloat())
    let t = p in poly
    if t == IN:
      echo 2
    elif t == ON:
      echo 1
    else:
      echo 0
