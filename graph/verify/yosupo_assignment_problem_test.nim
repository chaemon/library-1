# verify-helper: PROBLEM https://judge.yosupo.jp/problem/assignment

include "template/template.nim"
include "graph/template.nim"

include "graph/hungarian.nim"

proc main() =
  let
    N = nextInt()
    a = newSeqWith(N, newSeqWith(N, nextInt()))
  let (X, p) = a.hungarian()
  echo X
  echo p.mapIt($it).join(" ")

main()
