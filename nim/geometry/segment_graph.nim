# segment graph {{{
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=1033
# deduplication of line segments
proc merge_segments(segs: var seq[Segment]) =
  proc merge_if_able(s1: var Segment, s2: Segment):bool =
    if abs(cross(s1.b - s1.a, s2.b - s2.a)) > EPS: return false
    if ccw(s1.a, s2.a, s1.b) == 1 or ccw(s1.a, s2.a, s1.b) == -1: return false
    if ccw(s1.a, s1.b, s2.a) == -2 or ccw(s2.a, s2.b, s1.a) == -2: return false
    s1 = initSegment(min(s1.a, s2.a), max(s1.b, s2.b))
    return true

  for i in 0..<segs.len:
    if segs[i].b < segs[i].a: swap(segs[i].a, segs[i].b)
  for i in 0..<segs.len:
    var j = i + 1
    while j < segs.len:
      if merge_if_able(segs[i], segs[j]):
        segs[j] = segs.pop()
        j.dec
      j.inc
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=1033
# construct a graph with the vertex of the intersection of any two line segments
proc segment_arrangement(segs: seq[Segment]):(seq[Point], seq[seq[int]]) =
  var ps = newSeq[Point]()
  let N = segs.len
  for i in 0..<N:
    ps.add(segs[i].a)
    ps.add(segs[i].b)
    for j in i+1..<N:
      let 
        p1 = segs[i].b - segs[i].a
        p2 = segs[j].b - segs[j].a
      if cross(p1, p2) == 0: continue
      if intersect(segs[i], segs[j]):
        ps.add(crosspoint(segs[i], segs[j]))
# psをdeduplicateしたい。。。
  ps.sort(cmp[Point])
  block:
    var h, i = 0
    while i < ps.len:
      var j = i
      while j < ps.len and abs(ps[i] - ps[j]) < EPS: j.inc
      swap(ps[h], ps[i])
      i = j
      h.inc
    ps.setLen(h)

  let M = ps.len
  var g = newSeq[seq[int]](M)
  for i in 0..<N:
    var vec = newSeq[int]()
    for j in 0..<M:
      if intersect(segs[i], ps[j]):
        vec.add(j)
    for j in 1..<vec.len:
      g[vec[j - 1]].add(vec[j])
      g[vec[j]].add(vec[j - 1])
  return (ps, g)
# }}}
