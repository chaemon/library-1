#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=NTL_1_C"

include "../../template/template.nim"
include "../gcd.nim"

proc main() =
  let
    n = nextInt()
    a = newSeqWith(n, nextInt())
  var l = 1
  for t in a: l = lcm(l, t)
  echo l

main()
