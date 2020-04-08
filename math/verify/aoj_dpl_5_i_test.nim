# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_I

include "template/template.nim"

const MOD = 1000000007
include "math/mod_int.nim"
include "math/combination.nim"

include "math/stirling_number_second.nim"

proc main() =
  let N, K = nextInt()
  echo stirling_number_second[Mint](N, K)

main()
