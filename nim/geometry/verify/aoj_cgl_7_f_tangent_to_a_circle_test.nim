#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_F"

#define ERROR 1e-5

include "../../template/template.nim"
include "../template.nim"

block main:
  let
    p = initPoint(nextFloat(), nextFloat())
    c = initCircle(initPoint(nextFloat(), nextFloat()), nextFloat())
  var q = tangent(c, p)
  if q[0] > q[1]: swap(q[0], q[1])
  echo q[0].toString(), " ", q[1].toString()
