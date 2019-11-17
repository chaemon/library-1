#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=NTL_1_D"

include "../../template/template.nim"

include "../euler_phi.nim"

proc main() =
  let N = nextInt()
  echo eulerPhi(N)

main()
