# verify-helper: PROBLEM https://judge.yosupo.jp/problem/zalgorithm

include "template/template.nim"
include "string/z_algorithm.nim"

proc main() =
  let S = nextString()
  let a = S.z_algorithm()
  echo a.map(x => $x).join(" ")
  echo ""

main()
