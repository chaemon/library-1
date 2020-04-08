# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=NTL_1_B

include "template/template.nim"
include "math/mod_pow.nim"

proc main() =
  let
    M = nextInt()
    N = nextInt()
  echo modPow(M, N, 1000000007)

main()
