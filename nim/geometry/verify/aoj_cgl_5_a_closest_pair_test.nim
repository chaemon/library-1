#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_5_A"
#define ERROR 1e-6

include "../../template/template.nim"
include "../template.nim"

block main:
  let
    n = nextInt()
    g = newSeqWith(n, initPoint(nextFloat(), nextFloat()))
  echo g.closest_pair()
