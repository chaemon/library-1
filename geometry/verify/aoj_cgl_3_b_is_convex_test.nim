# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_3_B

include "template/template.nim"
include "geometry/template.nim"
include "geometry/polygon.nim"

block main:
  let
    n = nextInt()
    p = newSeqWith(n, initPoint(nextFloat(), nextFloat()))
  if p.isConvex(): echo 1
  else: echo 0
