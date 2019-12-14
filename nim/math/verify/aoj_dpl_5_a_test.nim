#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_A"

include "../../template/template.nim"

include "../mod_int.nim"

proc main() =
  let n, k = nextInt()
  echo initMint(k)^n

main()
