# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_E

include "template/template.nim"

const MOD = 1000000007

include "math/mod_int.nim"
include "math/combination.nim"

proc main() =
  let n, k = nextInt()
  echo Mint.C(k,n)

main()
