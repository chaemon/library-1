#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_G"

include "../../template/template.nim"

include "../mod_int.nim"
include "../combination.nim"

include "../bell_number.nim"

proc main() =
  let N, K = nextInt()
  echo bell_number[Mint](N, K)

main()
