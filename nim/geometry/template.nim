#include "../standard_library/complex.nim"
import complex, math
import sets, sequtils
import sugar

type
  Real = float
  Point = Complex[float]

let EPS:Real = 1e-8
#  PI = arccos(-1)

proc initPoint(re:float, im:float):Point = Point(re:re, im:im)
proc nextPoint():Point = return initPoint(nextFloat(), nextFloat())

proc `*`(p:Point, d:Real):Point =
  return Point(re:p.re * d, im:p.im * d)

proc toString(p:Point):string = $(p.re) & " " & $(p.im)

# rotate point p counterclockwise by theta rad
proc rotate(theta:Real, p:Point):Point =
  return initPoint(cos(theta) * p.re - sin(theta) * p.im, sin(theta) * p.re + cos(theta) * p.im)

proc radianToDegree(r:Real):Real = r * 180.0 / PI
proc degreeToRadian(d:Real):Real = d * PI / 180.0

# smaller angle of the a-b-c
proc getAngle(a,b,c:Point):Real =
  let
    v = b - a
    w = c - b
  var
    alpha = arctan2(v.im, v.re)
    beta = arctan2(w.im, w.re)
  if alpha > beta: swap(alpha, beta)
  let theta = beta - alpha
  return min(theta, 2.0 * PI - theta)

# comparison functions {{{
proc eq(a,b:Real):bool = return abs(b - a) < EPS
proc `==`(a,b:Point):bool =
  return abs(b - a) < EPS
proc `<`(a,b:Point):bool =
  if not eq(a.re, b.re): return a.re < b.re
  elif not eq(a.im, b.im): return a.im < b.im
  return false
proc `<=`(a,b:Point):bool =
  if not eq(a.re, b.re): return a.re < b.re
  elif not eq(a.im, b.im): return a.im < b.im
  return true
# }}}

type Line = object
  a, b:Point

type Segment {.borrow: `.`.} = distinct Line

proc initLine(a,b:Point):Line = Line(a:a, b:b)
proc initLine(A, B, C:Real):Line = # Ax + By = C
  var a, b: Point
  if eq(A, 0.0): a = initPoint(0.0, C / B); b = initPoint(1, C / B)
  elif eq(B, 0.0): b = initPoint(C / A, 0); b = initPoint(C / A, 1)
  else: a = initPoint(0, C / B); b = initPoint(C / A, 0)
  return initLine(a, b)

proc `$`(p:Line):string =
  return(p.a.toString & " to " & p.b.toString)
proc nextLine():Line = initLine(nextPoint(), nextPoint())

proc initSegment(a, b:Point):Segment = Segment(Line(a:a, b:b))

type
  Circle = object
    p:Point
    r:Real
  Points = seq[Point]
  Polygon = seq[Point]
  Segments = seq[Segment]
  Lines = seq[Line]
  Circles = seq[Circle]

proc initCircle(p:Point, r:Real):Circle = Circle(p:p, r:r)

proc cross(a,b:Point):Real = a.re * b.im - a.im * b.re
proc dot(a,b:Point):Real = a.re * b.re + a.im * b.im

proc norm(a:Point):Real = dot(a,a)

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_C
proc ccw(a, b, c: Point):int =
  var
    b = b - a
    c = c - a
  if cross(b, c) > EPS: return +1  # "COUNTER_CLOCKWISE"
  if cross(b, c) < -EPS: return -1 # "CLOCKWISE"
  if dot(b, c) < 0: return +2      # "ONLINE_BACK" c-a-b
  if norm(b) < norm(c): return -2  # "ONLINE_FRONT" a-b-c
  return 0                         # "ON_SEGMENT" a-c-b

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_A
proc parallel(a,b:Line):bool = eq(cross(a.b - a.a, b.b - b.a), 0.0)
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_A
proc orthogonal(a,b:Line):bool = eq(dot(a.a - a.b, b.a - b.b), 0.0)

# projection reflection {{{
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_A
proc projection(l:Line, p:Point):Point =
  let t = dot(p - l.a, l.a - l.b) / norm(l.a - l.b)
  return l.a + (l.a - l.b) * complex(t)
proc projection(l:Segment, p:Point):Point =
  let t = dot(p - l.a, l.a - l.b) / norm(l.a - l.b)
  return l.a + (l.a - l.b) * complex(t)
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_B
proc reflection(l:Line, p:Point):Point = return p + (projection(l, p) - p) * complex(2.0)
# }}}

# intersect function {{{
proc intersect(l:Line, p:Point):bool = abs(ccw(l.a, l.b, p)) != 1
proc intersect(l,m: Line):bool = abs(cross(l.b - l.a, m.b - m.a)) > EPS or abs(cross(l.b - l.a, m.b - l.a)) < EPS

proc intersect(s:Segment, p:Point):bool =
  ccw(s.a, s.b, p) == 0
proc intersect(l:Line, s:Segment):bool =
  cross(l.b - l.a, s.a - l.a) * cross(l.b - l.a, s.b - l.a) < EPS

proc distance(l:Line, p:Point):Real
proc intersect(c:Circle, l:Line):bool = distance(l, c.p) <= c.r + EPS

proc intersect(c:Circle, p:Point): bool = abs(abs(p - c.p) - c.r) < EPS

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_B
proc intersect(s, t: Segment):bool =
  return ccw(s.a, s.b, t.a) * ccw(s.a, s.b, t.b) <= 0 and ccw(t.a, t.b, s.a) * ccw(t.a, t.b, s.b) <= 0

proc intersect(c:Circle, l:Segment):int =
  if norm(projection(l, c.p) - c.p) - c.r * c.r > EPS: return 0
  let
    d1 = abs(c.p - l.a)
    d2 = abs(c.p - l.b)
  if d1 < c.r + EPS and d2 < c.r + EPS: return 0
  if d1 < c.r - EPS and d2 > c.r + EPS or d1 > c.r + EPS and d2 < c.r - EPS: return 1
  let h:Point = projection(l, c.p)
  if dot(l.a - h, l.b - h) < 0: return 2
  return 0

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_A
proc intersect(c1, c2: Circle):int =
  var (c1, c2) = (c1, c2)
  if c1.r < c2.r: swap(c1, c2)
  let d = abs(c1.p - c2.p)
  if c1.r + c2.r < d: return 4
  if eq(c1.r + c2.r, d): return 3
  if c1.r - c2.r < d: return 2
  if eq(c1.r - c2.r, d): return 1
  return 0
# }}}

# distance function {{{
proc distance(a, b:Point):Real = abs(a - b)
proc distance(l:Line, p:Point):Real = abs(p - projection(l, p))
proc distance(l, m: Line):Real = (if intersect(l, m): 0.0 else: distance(l, m.a))

proc distance(s:Segment, p:Point):Real =
  let r = projection(s, p)
  if intersect(s, r): return abs(r - p)
  return min(abs(s.a - p), abs(s.b - p))

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_D
proc distance(a, b:Segment):Real =
  if intersect(a, b): return 0
  return min(min(distance(a, b.a), distance(a, b.b)), min(distance(b, a.a), distance(b, a.b)))
proc distance(l:Line, s:Segment):Real =
  if intersect(l, s): return 0
  return min(distance(l, s.a), distance(l, s.b));
# }}}

# crosspoint function {{{
proc crosspoint(l,m:Line):Point =
  let
    A = cross(l.b - l.a, m.b - m.a)
    B = cross(l.b - l.a, l.b - m.a)
  if eq(abs(A), 0.0) and eq(abs(B), 0.0): return m.a
  return m.a + (m.b - m.a) * complex(B) / A

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_C
proc crosspoint(l,m:Segment):Point =
  return crosspoint(Line(l), Line(m));

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_D
proc crosspoint(c:Circle, l:Line):(Point,Point) =
  let pr = projection(l, c.p)
  let e = (l.b - l.a) / abs(l.b - l.a)
  if eq(distance(l, c.p), c.r): return (pr, pr)
  let base = sqrt(c.r * c.r - norm(pr - c.p))
  return (pr - e * complex(base), pr + e * complex(base))

proc crosspoint(c:Circle, l:Segment):(Point,Point) =
  let
    aa = cast[Line](l)
  if intersect(c, l) == 2: return crosspoint(c, aa)
  result = crosspoint(c, aa)
  if dot(l.a - result[0], l.b - result[0]) < 0: result[1] = result[0]
  else: result[0] = result[1]

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_E
proc crosspoint(c1, c2: Circle):(Point,Point) =
  let
    d = abs(c1.p - c2.p)
    a = arccos((c1.r * c1.r + d * d - c2.r * c2.r) / (2 * c1.r * d))
    t = arctan2(c2.p.im - c1.p.im, c2.p.re - c1.p.re)
  return (c1.p + initPoint(cos(t + a) * c1.r, sin(t + a) * c1.r),
          c1.p + initPoint(cos(t - a) * c1.r, sin(t - a) * c1.r))
# }}}

# tangent function {{{
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_F
# tangent of circle c through point p
proc tangent(c1: Circle, p2:Point):(Point, Point) =
  return crosspoint(c1, initCircle(p2, sqrt(norm(c1.p - p2) - c1.r * c1.r)))

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_G
# common tangent of circles c1 and c2
proc tangent(c1, c2: Circle):Lines =
  result = newSeq[Line]()
  if c1.r < c2.r:
    result = tangent(c2, c1)
    for l in result.mitems:
      swap(l.a, l.b)
    return
  let g = norm(c1.p - c2.p)
  if eq(g, 0): return
  let
    u = (c2.p - c1.p) / sqrt(g)
#    v = rotate(PI * 0.5, u)
    xx = rotate(PI * 0.5, initPoint(1.0, 0.0))
    v = initPoint(- u.im, u.re)
  for s in [-1, 1]:
    let h = (c1.r + s.float * c2.r) / sqrt(g)
    if eq(1 - h * h, 0):
      result.add(initLine(c1.p + u * c1.r.complex, c1.p + (u + v) * c1.r.complex))
    elif 1 - h * h > 0:
      let
        uu = u * h.complex
        vv = v * sqrt(1 - h * h).complex
      result.add(initLine(c1.p + (uu + vv) * c1.r.complex, c2.p - (uu + vv) * c2.r.complex * s.float.complex))
      result.add(initLine(c1.p + (uu - vv) * c1.r.complex, c2.p - (uu - vv) * c2.r.complex * s.float.complex))
# }}}
