# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_4_B
# verify-helper: ERROR 1e-6

include "template/template.nim"
include "geometry/template.nim"
include "geometry/polygon.nim"

block main:
  let
    n = nextInt()
    p = newSeqWith(n, initPoint(nextFloat(), nextFloat()))
  echo p.convex_diameter()
