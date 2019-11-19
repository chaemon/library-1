#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DSL_2_G"

include "../../template/template.nim"

include "../lazy_segment_tree.nim"

proc main() =
  let n, q = nextInt()
  var st = newLazySegmentTree[(int,int),int](n, (a:(int,int),b:(int,int)) => (a[0] + b[0], a[1] + b[1]), (a:(int,int), b:int) => (a[0] + b * a[1], a[1]), (a:int, b:int) => a+b, (0,1), 0)
  st.build(newSeqWith(n,(0,1)))
  for i in 0..<q:
    let p = nextInt()
    let s, t = nextInt() - 1
    if p == 0:
      let x = nextInt()
      st.update(s, t + 1, x)
    else:
      echo st.query(s, t + 1)[0]

main()
