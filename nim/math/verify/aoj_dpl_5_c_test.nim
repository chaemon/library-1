#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_C"

include "../../template/template.nim"

include "../mod_int.nim"
include "../combination.nim"

proc main() =
  let n, k = nextInt()
  var
    T = newCombination[Mint](k)
    s = newMint(0)
  for i in 1..k:
    if (k - i) mod 2 == 0: s += T.C(k,i) * newMint(i).pow(n)
    else: s -= T.C(k,i) * newMint(i).pow(n)
  echo s

main()
