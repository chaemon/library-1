#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_2_A"

include "../../template/template.nim"
include "../template.nim"

include "../../structure/union_find.nim"

include "../boruvka.nim"

proc main() =
  let V, E = nextInt()
  var es = newSeq[Edge[int]]()
  for i in 0..<E:
    let x,y,z = nextInt()
    es.add(newEdge(x,y,z))
  let INF = (1 shl 30)
  let f = proc(sz:int, belong:seq[int]):seq[(int,int)] =
    var ret = newSeqWith(sz, (INF, -1))
    for e in es:
      if belong[e.src] == belong[e.dst]: continue
      ret[belong[e.src]] = min(ret[belong[e.src]], (e.weight, belong[e.dst]))
      ret[belong[e.dst]] = min(ret[belong[e.dst]], (e.weight, belong[e.src]))
    return ret
  echo boruvka[int, proc(sz:int, belong:seq[int]):seq[(int,int)]](V, f)

main()
