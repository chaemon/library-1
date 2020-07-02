# verify-helper: PROBLEM https://judge.yosupo.jp/problem/suffixarray

include "template/template.nim"
include "string/suffix_array.nim"

proc main() =
  let S = nextString()

  var sa = initSuffixArray(S);
  echo sa.SA.mapIt($it).join(" ")

main()
