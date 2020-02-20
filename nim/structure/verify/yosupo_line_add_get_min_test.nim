#define PROBLEM "https://judge.yosupo.jp/problem/line_add_get_min"

include "../../template/template.nim"

include "../li_chao_tree.nim"

proc main() =
  let N, Q = nextInt()
  var a, b = newSeq[int]()
  var xs = newSeq[int]()
  for i in 0..<N:
    a.add(nextInt())
    b.add(nextInt())
  var q = newSeq[seq[int]]()
  for i in 0..<Q:
    let t = nextInt()
    if t == 0:
      let a, b = nextInt()
      q.add(@[t,a,b])
    else:
      let p = nextInt()
      q.add(@[t,p])
      xs.add(p)
  xs.sort()
  xs = xs.toOrderedSet.mapIt(it)
  var lct = initLiChaoTree[int](xs, int.inf)
  for i in 0..<N:
    lct.update(a[i], b[i])
  for i in 0..<Q:
    if q[i][0] == 0:
      lct.update(q[i][1], q[i][2])
    else:
      echo lct.query(xs.binarySearch(q[i][1]))

main()
