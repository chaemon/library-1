# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=NTL_1_E

include "template/template.nim"

include "math/gcd.nim"

proc main() =
  let a, b = nextInt()
  var
    x:int
    y:int
  discard extGcd(a, b, x, y)
  echo x, " ", y

main()
