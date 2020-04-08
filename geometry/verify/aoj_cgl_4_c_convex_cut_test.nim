# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_4_C
# verify-helper: ERROR 1e-6

include "template/template.nim"
include "geometry/template.nim"
include "geometry/polygon.nim"

block main:
  let
    n = nextInt()
    g = newSeqWith(n, initPoint(nextFloat(), nextFloat()))
    q = nextInt()
  for i in 0..<q:
    let p1, p2 = initPoint(nextFloat(), nextFloat())
    echo g.convexCut(initLine(p1, p2)).area()
