#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_L"

include "../../template/template.nim"

include "../mod_int.nim"

include "../partition_table.nim"

proc main() =
  let N, K = nextInt()
  if N - K < 0: echo 0
  else: echo getPartition[Mint[MOD]](N - K, K)[N - K][K]

main()
