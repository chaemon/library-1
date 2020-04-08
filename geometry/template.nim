import math
import complex
import sets, sequtils

type
  Real = float
  Point = Complex[float]

#let EPS:Real = 1e-8
#  PI = arccos(-1)

proc initPoint(re:float, im:float):Point = Point(re:re, im:im)
proc nextPoint():Point = return initPoint(nextFloat(), nextFloat())

proc `*`(p:Point, d:Real):Point =
  return Point(re:p.re * d, im:p.im * d)

proc toString(p:Point):string = $(p.re) & " " & $(p.im)

# rotate point p counterclockwise by theta rad
proc rotate(theta:Real, p:Point):Point =
  return initPoint(cos(theta) * p.re - sin(theta) * p.im, sin(theta) * p.re + cos(theta) * p.im)

proc radianToDegree(r:Real):Real = r * 180.Real / PI
proc degreeToRadian(d:Real):Real = d * PI / 180.Real

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
  return min(theta, 2.Real * PI - theta)

# float comp {{{
const EPS = 1e-9

proc eq(a,b:float):bool = system.`<`(abs(a - b), EPS)
proc ne(a,b:float):bool = system.`>`(abs(a - b), EPS)
proc lt(a,b:float):bool = system.`<`(a + EPS, b)
proc gt(a,b:float):bool = system.`>`(a, b + EPS)
proc le(a,b:float):bool = system.`<`(a, b + EPS)
proc ge(a,b:float):bool = system.`>`(a + EPS, b)
# }}}

# comparison functions {{{
#proc eq(a,b:Real):bool = return abs(b - a) < EPS
proc eq(a,b:Point):bool =
  return eq(a.re, b.re) and eq(a.im, b.im)
#  return system.`<`(abs(b - a), EPS)

proc lt(a,b:Point):bool =
  if ne(a.re, b.re): return lt(a.re, b.re)
  elif ne(a.im, b.im): return lt(a.im, b.im)
  return false
proc `<`(a,b:Point):bool = return a.lt b

proc le(a,b:Point):bool =
  if ne(a.re, b.re): return lt(a.re, b.re)
  elif ne(a.im, b.im): return lt(a.im, b.im)
  return true
proc `<=`(a,b:Point):bool = return a.le b
# }}}

# Line and Segment {{{
type Line = object
  a, b:Point

type Segment {.borrow: `.`.} = distinct Line

proc initLine(a,b:Point):Line = Line(a:a, b:b)
proc initLine(A, B, C:Real):Line = # Ax + By = C
  var a, b: Point
  if A.eq 0.Real: a = initPoint(0.Real, C / B); b = initPoint(1.Real, C / B)
  elif B.eq 0.Real: b = initPoint(C / A, 0.Real); b = initPoint(C / A, 1.Real)
  else: a = initPoint(0.Real, C / B); b = initPoint(C / A, 0.Real)
  return initLine(a, b)

proc `$`(p:Line):string =
  return(p.a.toString & " to " & p.b.toString)
proc nextLine():Line = initLine(nextPoint(), nextPoint())

proc initSegment(a, b:Point):Segment = Segment(Line(a:a, b:b))
proc nextSegment():Segment = initSegment(nextPoint(), nextPoint())
# }}}

# Circle {{{
type Circle = object
  p:Point
  r:Real

proc initCircle(p:Point, r:Real):Circle = Circle(p:p, r:r)
# }}}

proc cross(a,b:Point):Real = a.re * b.im - a.im * b.re
proc dot(a,b:Point):Real = a.re * b.re + a.im * b.im

proc norm(a:Point):Real = dot(a,a)

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_C
proc ccw(a, b, c: Point):int =
  var
    b = b - a
    c = c - a
  if cross(b, c).gt(0.Real): return +1  # "COUNTER_CLOCKWISE"
  if cross(b, c).lt(-0.Real): return -1 # "CLOCKWISE"
  if dot(b, c).lt(0): return +2      # "ONLINE_BACK" c-a-b
  if norm(b).lt(norm(c)): return -2  # "ONLINE_FRONT" a-b-c
  return 0                         # "ON_SEGMENT" a-c-b

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_A
proc parallel(a,b:Line):bool = cross(a.b - a.a, b.b - b.a).eq(0.Real)
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_A
proc orthogonal(a,b:Line):bool = dot(a.a - a.b, b.a - b.b).eq(0.Real)

# projection reflection {{{
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_A
proc projection(p:Point, l:Line):Point =
  let t = dot(p - l.a, l.a - l.b) / norm(l.a - l.b)
  return l.a + (l.a - l.b) * complex(t)
proc projection(p:Point, l:Segment):Point =
  let t = dot(p - l.a, l.a - l.b) / norm(l.a - l.b)
  return l.a + (l.a - l.b) * complex(t)
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_B
proc reflection(p:Point, l:Line):Point = return p + (p.projection(l) - p) * complex(2.0)
# }}}

# intersect function {{{
proc intersect(l:Line, p:Point):bool = abs(ccw(l.a, l.b, p)) != 1
proc intersect(l,m: Line):bool = abs(cross(l.b - l.a, m.b - m.a)).gt(0.Real) or abs(cross(l.b - l.a, m.b - l.a)).lt(0.Real)

proc intersect(s:Segment, p:Point):bool =
  ccw(s.a, s.b, p) == 0
proc intersect(l:Line, s:Segment):bool =
  (cross(l.b - l.a, s.a - l.a) * cross(l.b - l.a, s.b - l.a)).lt(0.Real)

proc distance(l:Line, p:Point):Real
proc intersect(c:Circle, l:Line):bool = distance(l, c.p) <= c.r

proc intersect(c:Circle, p:Point): bool = abs(abs(p - c.p) - c.r) < 0.Real

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_B
proc intersect(s, t: Segment):bool =
  return ccw(s.a, s.b, t.a) * ccw(s.a, s.b, t.b) <= 0 and ccw(t.a, t.b, s.a) * ccw(t.a, t.b, s.b) <= 0

proc intersect(c:Circle, l:Segment):int =
  if (norm(c.p.projection(l) - c.p) - c.r * c.r).gt 0.Real: return 0
  let
    d1 = abs(c.p - l.a)
    d2 = abs(c.p - l.b)
  if d1.le(c.r) and d2.le(c.r): return 0
  if d1.lt(c.r) and d2.gt(c.r) or d1.gt(c.r) and d2.lt(c.r): return 1
  let h:Point = c.p.projection(l)
  if dot(l.a - h, l.b - h).lt(0.Real): return 2
  return 0

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_A
# number of common tangent
proc intersect(c1, c2: Circle):int =
  var (c1, c2) = (c1, c2)
  if c1.r.lt c2.r: swap(c1, c2)
  let d = abs(c1.p - c2.p)
  if(c1.r + c2.r).lt d: return 4
  if(c1.r + c2.r).eq d: return 3
  if(c1.r - c2.r).lt d: return 2
  if(c1.r - c2.r).eq d: return 1
  return 0
# }}}

# distance function {{{
proc distance(a, b:Point):Real = abs(a - b)
proc distance(l:Line, p:Point):Real = abs(p - p.projection(l))
proc distance(l, m: Line):Real = (if intersect(l, m): 0.Real else: distance(l, m.a))

proc distance(s:Segment, p:Point):Real =
  let r = p.projection(s)
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
  if (abs(A).eq 0.Real) and (abs(B).eq 0.Real): return m.a
  return m.a + (m.b - m.a) * complex(B) / A

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_C
proc crosspoint(l,m:Segment):Point =
  return crosspoint(Line(l), Line(m));

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_D
proc crosspoint(c:Circle, l:Line):(Point,Point) =
  let pr = c.p.projection(l)
  let e = (l.b - l.a) / abs(l.b - l.a)
  if distance(l, c.p).eq c.r: return (pr, pr)
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

