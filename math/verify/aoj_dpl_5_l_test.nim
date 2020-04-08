# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_L

include "template/template.nim"

const MOD = 1000000007
include "math/mod_int.nim"

include "math/partition_table.nim"

proc main() =
  let N, K = nextInt()
  if N - K < 0: echo 0
  else: echo getPartition[Mint](N - K, K)[N - K][K]

main()
