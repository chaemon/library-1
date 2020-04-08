# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_D
# verify-helper: ERROR 1e-6

include "template/template.nim"
include "geometry/template.nim"

block main:
  let
    c = initCircle(initPoint(nextFloat(), nextFloat()), nextFloat())
    q = nextInt()
  for i in 0..<q:
    let p1, p2 = nextPoint()
    let l = initLine(p1, p2)
    var q = crosspoint(c, l)
    if q[0] > q[1]: swap(q[0], q[1])
    echo q[0].toString(), " ", q[1].toString()
