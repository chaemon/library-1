#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DSL_2_H"

include "../../template/template.nim"

include "../lazy_segment_tree.nim"

proc main() =
  let n, q = nextInt()
  var st = initLazySegmentTree[int,int](n, (a:int,b:int) => min(a,b), (a:int, b:int) => (if a == int.inf: a else: a + b), (a:int, b:int) => a+b, int.inf, 0)
  st.build(newSeqWith(n,0))
  for i in 0..<q:
    let p, s, t = nextInt()
    if p == 0:
      let x = nextInt()
      st.update(s..t, x)
    else:
      echo st.query(s..t)

main()
