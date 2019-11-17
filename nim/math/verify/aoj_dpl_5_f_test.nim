#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_F"

include "../../template/template.nim"

include "../mod_int.nim"
include "../combination.nim"

proc main() =
  let n, k = nextInt()
  var T = newCombination[Mint]()
  echo T.C(n-1,k-1)

main()
