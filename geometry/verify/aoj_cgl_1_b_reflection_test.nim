# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_B
# verify-helper: ERROR 1e-8

include "template/template.nim"
include "geometry/template.nim"

block main:
  let
    xp1, yp1, xp2, yp2 = nextFloat()
    p1 = initPoint(xp1, yp1)
    p2 = initPoint(xp2, yp2)
  let q = nextInt()
  for i in 0..<q:
    let
      xp, yp = nextFloat()
      p = initPoint(xp, yp)
    echo p.reflection(initLine(p1, p2)).toString()
