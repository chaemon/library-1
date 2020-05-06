# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_1_D

include "template/template.nim"

include "standard_library/upperBound.nim"
include "dp/longest_increasing_subsequence.nim"


proc main() =
  let
    N = nextInt()
    A = newSeqWith(N, nextInt())
  echo longestIncreasingSubsequence(A, true)

main()
