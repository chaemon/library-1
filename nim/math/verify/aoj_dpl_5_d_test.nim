#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_D"

include "../../template/template.nim"

include "../mod_int.nim"
include "../combination.nim"

proc main() =
  let n, k = nextInt()
  var T = initCombination[Mint](n+k-1)
  echo T.C(n+k-1,n)

main()
