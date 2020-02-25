#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=DSL_2_I"

include "../../template/template.nim"

include "../lazy_segment_tree.nim"

proc main() =
  let n, q = nextInt()
  const null = 2019
  var st = initLazySegmentTree[(int,int),int](n, (a:(int,int),b:(int,int)) => (a[0] + b[0], a[1] + b[1]), (a:(int,int), b:int) => (if b == null: a else: (b * a[1], a[1])), (a:int, b:int) => b, (0,1), null)
  st.build(newSeqWith(n,(0,1)))
  for i in 0..<q:
    let p, s, t = nextInt()
    if p == 0:
      let x = nextInt()
      st.update(s..t, x)
    else:
      echo st[s..t][0]

main()
