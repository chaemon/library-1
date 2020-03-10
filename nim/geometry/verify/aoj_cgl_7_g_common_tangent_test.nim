#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_G"
#define ERROR 1e-5

include "../../template/template.nim"
include "../template.nim"
include "../tangent.nim"

block main:
  let
    c1, c2 = initCircle(initPoint(nextFloat(), nextFloat()), nextFloat())
    q = tangent(c1, c2)
  var ans = newSeq[Point]()
  for l in q:
    if distance(l.a, c1.p).eq c1.r:
      ans.add l.a
    else:
      ans.add l.b
  ans.sort()
  for a in ans:
    echo a.toString()
