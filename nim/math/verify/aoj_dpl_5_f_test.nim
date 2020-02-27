#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_F"

include "../../template/template.nim"

const MOD = 1000000007
include "../mod_int.nim"
include "../combination.nim"

proc main() =
  let n, k = nextInt()
  echo Mint.C(n-1,k-1)

main()
