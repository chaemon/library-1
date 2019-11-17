#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=ALDS1_3_B"

include "../../template/template.nim"

include "../deque.nim"

proc main() =
  var que = initDeque[(string, int)]()
  let n,q = nextInt()
  for i in 0..<n:
    let name = nextString()
    let time = nextInt()
    que.addLast((name, time))
  var t = 0
  while que.len > 0:
    var (name, time) = que.popFirst()
    if time <= q:
      t += time
      echo name, " ", t
    else:
      t += q
      time -= q
      que.addLast((name, time))

main()
