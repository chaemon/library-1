#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_C"

#define ERROR 1e-8

include "../../template/template.nim"
include "../template.nim"

block main:
  let q = nextInt()
  for i in 0..<q:
    var p = newSeqWith(4, initPoint(nextFloat(), nextFloat()))
    echo crossPoint(initSegment(p[0], p[1]), initSegment(p[2], p[3])).toString()
