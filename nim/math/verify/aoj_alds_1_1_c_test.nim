#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=ALDS1_1_C"

include "../../template/template.nim"

include "../is_prime.nim"

proc main() =
  let N = nextInt()
  var ret = 0
  for i in 0..<N:
    let x = nextInt()
    if isPrime(x): ret += 1
  echo ret

main()
