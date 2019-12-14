#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DPL_3_C"

include "../../template/template.nim"

include "../largest_rectangle.nim"

proc main() =
  let N = nextInt()
  var h = newSeqWith(N, nextInt())
  echo largestRectangle(h)

main()
