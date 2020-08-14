# verify-helper: PROBLEM https://judge.yosupo.jp/problem/runenumerate

include "template/template.nim"
include "string/z_algorithm.nim"
include "string/run_enumerate.nim"

proc main() =
  let
    s = nextString()
    ans = RunEnumerate(s)
  echo ans.len
  for (t,l,r) in ans:
    echo t, " ",l, " ",r

main()
