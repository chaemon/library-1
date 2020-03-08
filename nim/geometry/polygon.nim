#include "./template.nim"

type Polygon = seq[Point]

# convex polygon {{{
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_3_B
proc isConvex(p:Polygon):bool =
  let n = p.len
  for i in 0..<n:
    if ccw(p[(i + n - 1) mod n], p[i], p[(i + 1) mod n]) == -1: return false
  return true

import algorithm

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_4_A
proc convexHull(p:Polygon, strict = false): Polygon =
  let n = p.len
  var eps_cmp =
    if strict: (a:Real) => a <= 0.Real
    else: (a:Real) => a < 0.Real
#  let eps = if strict: EPS else: -EPS
  var
    k = 0
    p = p
  if n <= 2: return p
  p.sort(cmp[Point])
  var
    ch = newSeq[Point](2 * n)
    i = 0
  while i < n:
    while k >= 2 and cross(ch[k - 1] - ch[k - 2], p[i] - ch[k - 1]).eps_cmp: k.dec
    ch[k] = p[i]
    k.inc;i.inc
  i = n - 2
  let t = k + 1
  while i >= 0:
    while k >= t and cross(ch[k - 1] - ch[k - 2], p[i] - ch[k - 1]).eps_cmp: k.dec
    ch[k] = p[i]
    k.inc;i.dec
  ch.setLen(k - 1)
  return ch

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_4_C
# cut with a straight line l and return a convex polygon on the left
proc convex_cut(U: Polygon, l:Line):Polygon =
  result = newSeq[Point]()
  for i in 0..<U.len:
    let
      now = U[i]
      nxt = U[(i + 1) mod U.len]
    if ccw(l.a, l.b, now) != -1: result.add(now)
    if ccw(l.a, l.b, now) * ccw(l.a, l.b, nxt) < 0:
      result.add(crosspoint(initLine(now, nxt), l))

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_4_B
proc convex_diameter(p: Polygon):Real =
  let N = p.len
  var
    it = 0
    jt = 0
  for i in 1..<N:
    if p[i].im > p[it].im: it = i
    if p[i].im < p[jt].im: jt = i
  var maxdis = norm(p[it] - p[jt])

  var
    i, maxi = it
    j, maxj = jt
  while true:
    if cross(p[(i + 1) mod N] - p[i], p[(j + 1) mod N] - p[j]) >= 0:
      j = (j + 1) mod N
    else:
      i = (i + 1) mod N
    if norm(p[i] - p[j]) > maxdis:
      maxdis = norm(p[i] - p[j])
      maxi = i
      maxj = j
    if not (i != it or j != jt): break
  return sqrt(maxdis)


# }}}

# polygon {{{
# contains {{{
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_3_C
type State = enum
  OUT, ON, IN

proc contains(Q: Polygon, p:Point):State =
  var inside = false;
  for i in 0..<Q.len:
    var
      a = Q[i] - p
      b = Q[(i + 1) mod Q.len] - p
    if a.im > b.im: swap(a, b)
    if a.im <= 0 and 0 < b.im and cross(a, b) < 0: inside = not inside
    if cross(a, b) == 0 and dot(a, b) <= 0: return ON
  return if inside: IN else: OUT
# }}}

# area {{{
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_3_A
proc area(p: Polygon):Real =
  var A = 0.Real
  for i in 0..<p.len:
    A += cross(p[i], p[(i + 1) mod p.len])
  return A * 0.5

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_H
proc area(p:Polygon, c:Circle):Real =
  if p.len < 3: return 0.0
  proc cross_area(c: Circle, a,b: Point):Real =
    let
      va = c.p - a
      vb = c.p - b
      f = cross(va, vb)
    result = 0.Real
    if f == 0.Real:
      return
    if max(abs(va), abs(vb)) <= c.r: return f
    if c.r <= distance(initSegment(a, b), c.p):
      return c.r * c.r * phase(vb * conjugate(va))
    let u = crosspoint(c, initSegment(a, b))
    let tot = @[a, u[0], u[1], b]
    for i in 0..<tot.len:
      result += cross_area(c, tot[i], tot[i + 1])
  var A = 0.Real
  for i in 0..<p.len:
    A += cross_area(c, p[i], p[(i + 1) mod p.len]) * 0.5
  return A
# }}}
# }}}
