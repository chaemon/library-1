#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_J"

include "../../template/template.nim"

include "../mod_int.nim"

include "../partition_table.nim"

proc main() =
  let N, K = nextInt()
  echo get_partition[Mint[MOD]](N, K)[N][K]

main()
