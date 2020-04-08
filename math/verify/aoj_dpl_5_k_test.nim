# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_5_K

include "template/template.nim"

proc main() =
  let n, k = nextInt()
  echo if n <= k: 1 else: 0

main()
