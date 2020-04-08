# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_E
# verify-helper: ERROR 1e-6

include "template/template.nim"
include "geometry/template.nim"

block main:
  let
    c1, c2 = initCircle(initPoint(nextFloat(), nextFloat()), nextFloat())
  var  v = cross_point(c1, c2)
  if v[0] > v[1]: swap(v[0], v[1])
  echo v[0].toString(), " ", v[1].toString()
