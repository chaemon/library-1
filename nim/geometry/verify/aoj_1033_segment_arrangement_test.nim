#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=1033"
#define ERROR 1e-5

include "../../template/template.nim"
include "../template.nim"
include "../segment_graph.nim"
include "../../graph/template.nim"
include "../../graph/dijkstra.nim"

block main:
  while true:
    let n = nextInt()
    if n == 0: break
    var segs = newSeq[Segment]()
    for i in 0..<n:
      let p, q = initPoint(nextFloat(), nextFloat())
      segs.add(initSegment(p, q))
    let start, goal = initPoint(nextFloat(), nextFloat())
    var (ps, g) = segment_arrangement(segs)
    for v in g.mitems:
      var hs = v.toHashSet()
      v.setlen(0)
      for h in hs: v.add(h)
      v.sort()
    var si, gi = -1
    for i,p in ps:
      if start == ps[i]: si = i
      if goal == ps[i]: gi = i
    assert(si >= 0 and gi >= 0)
    proc id(x, y:int):int = y * ps.len + x
    proc rev_id(t:int):(int,int) = (t mod ps.len, t div ps.len)
    var G = initGraph[float](ps.len^2 + 1)
    let src = ps.len^2
    for u in 0..<ps.len:
      if u == si: continue
      G.addEdge(src, id(si, u), 0.0)
    for u in 0..<ps.len:
      for v in g[u]:
        for w in g[v]:
          let d = polar((ps[w] - ps[v])/(ps[v] - ps[u]))[1]
          G.addEdge(id(u, v), id(v, w), abs(d))
    let (dist, _) = G.dijkstra(src)
    var ans = float.inf
    for u in 0..<ps.len:
      for v in g[u]:
        if v != gi: continue
        ans.min= dist[id(u, v)]
    if ans == float.inf:
      echo -1
    else:
      echo ans.radianToDegree
