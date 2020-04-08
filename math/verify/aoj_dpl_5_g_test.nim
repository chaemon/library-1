# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_G

include "template/template.nim"

const MOD = 1000000007
include "math/mod_int.nim"
include "math/combination.nim"

include "math/bell_number.nim"

proc main() =
  let N, K = nextInt()
  echo bellNumber[Mint](N, K)

main()
