#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_C"

include "../../template/template.nim"

const MOD = 1000000007
include "../mod_int.nim"
include "../combination.nim"

proc main() =
  let n, k = nextInt()
  var
    T = initCombination[Mint](k)
    s = initMint(0)
  for i in 1..k:
    if (k - i) mod 2 == 0: s += T.C(k,i) * (initMint(i)^n)
    else: s -= T.C(k,i) * (initMint(i)^n)
  echo s

main()
