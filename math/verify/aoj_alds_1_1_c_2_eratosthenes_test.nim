# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=ALDS1_1_C

include "template/template.nim"

include "math/eratosthenes.nim"

proc main() =
  let
    p = initEratosthenes(100000000)
    N = nextInt()
  var ret = 0;
  for i in 0..<N:
    let x = nextInt()
    if p.isPrime(x): ret += 1
  echo ret

main()
