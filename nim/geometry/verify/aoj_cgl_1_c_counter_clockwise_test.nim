#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_C"

include "../../template/template.nim"
include "../template.nim"

block main:
  let
    xp0, yp0, xp1, yp1 = nextFloat()
    p0 = initPoint(xp0, yp0)
    p1 = initPoint(xp1, yp1)
  let q = nextInt()
  for i in 0..<q:
    let
      xp2, yp2 = nextFloat()
      p2 = initPoint(xp2, yp2)
      c = ccw(p0, p1, p2)
    if c == 1:    echo "COUNTER_CLOCKWISE"
    elif c == -1: echo "CLOCKWISE"
    elif c == 2: echo "ONLINE_BACK"
    elif c == -2: echo "ONLINE_FRONT"
    else: echo "ON_SEGMENT"
