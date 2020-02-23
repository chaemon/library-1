#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DSL_2_A"

include "../../template/template.nim"

include "../segment_tree.nim"

proc main() =
  let N, Q = nextInt()
  let inf = (1 shl 31) - 1
  var st = initSegmentTree[int](N, (a:int,b:int)=>min(a,b), inf)
  st.build(newSeqWith(N,inf))
  for i in 0..<Q:
    let T, X, Y = nextInt()
    if T == 0: st[X] = Y
    else: echo st[X..Y]

main()
