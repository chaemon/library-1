# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_5_A
# verify-helper: ERROR 1e-6

include "template/template.nim"
include "geometry/template.nim"
include "geometry/closest_pair.nim"

block main:
  let
    n = nextInt()
    g = newSeqWith(n, initPoint(nextFloat(), nextFloat()))
  echo g.closest_pair()
