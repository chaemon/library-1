#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=NTL_1_B"

include "../../template/template.nim"
const MOD = 1000000007
include "../mod_int.nim"
include "../mod_pow.nim"

proc main() =
  let
    M = initMint(nextInt())
    N = nextInt()
  echo M^N

main()
