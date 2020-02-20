#define PROBLEM "https://judge.yosupo.jp/problem/segment_add_get_min"

include "../../template/template.nim"

include "../li_chao_tree.nim"

proc main() =
  let N, Q = nextInt()
  var l, r, a, b = newSeq[int]()
  var xs = newSeq[int]()
  for i in 0..<N:
    l.add(nextInt())
    r.add(nextInt())
    a.add(nextInt())
    b.add(nextInt())
    xs.add(l[^1])
    xs.add(r[^1])
  var q = newSeq[seq[int]]()
  for i in 0..<Q:
    let t = nextInt()
    if t == 0:
      let l, r, a, b = nextInt()
      q.add(@[t,l,r,a,b])
      xs.add(l)
      xs.add(r)
    else:
      let p = nextInt()
      q.add(@[t,p])
      xs.add(p)
  xs.sort()
  xs = xs.toOrderedSet.mapIt(it)
  var lct = initLiChaoTree[int](xs, int.inf)
  for i in 0..<N:
    var
      li = xs.binarySearch(l[i])
      ri = xs.binarySearch(r[i])
    assert xs[li] == l[i] and xs[ri] == r[i]
    lct.update(a[i], b[i], li..<ri)
  for i in 0..<Q:
    if q[i][0] == 0:
      var
        li = xs.binarySearch(q[i][1])
        ri = xs.binarySearch(q[i][2])
      assert xs[li] == q[i][1] and xs[ri] == q[i][2]
      lct.update(q[i][3], q[i][4], li..<ri)
    else:
      let y = lct.query(xs.binarySearch(q[i][1]))
      if y == int.inf:
        echo "INFINITY"
      else:
        echo y

main()
