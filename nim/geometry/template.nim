include "../standard_library/complex.nim"

type
  Real = float
  Point = Complex

proc initPoint(re:float, im:float):Point = Point(re:re, im:im)

let
  EPS:Real = 1e-8
#  PI = arccos(-1)

proc eq(a,b:Real):bool = return abs(b - a) < EPS

proc `*`(p:Point, d:Real):Point =
  return Point(re:p.re * d, im:p.im * d)

#istream &operator>>(istream &is, Point &p) {
#  Real a, b;
#  is >> a >> b;
#  p = Point(a, b);
#  return is;
#}
#
#ostream &operator<<(ostream &os, Point &p) {
#  return os << fixed << setprecision(10) << p.re << " " << p.im;
#}

# rotate point p counterclockwise by theta rad
proc rotate(theta:Real, p:Point):Point =
  return Point(re:cos(theta) * p.re - sin(theta) * p.im, im:sin(theta) * p.re + cos(theta) * p.im)

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
  return min(theta, 2 * arccos(-1) - theta)

proc `<`(a,b:Point):bool =
  if a.re != b.re: a.re < b.re else: a.im < b.im

type Line = object
  a, b:Point

proc initLine(a,b:Point):Line = Line(a:a, b:b)

proc initLine(A, B, C:Real):Line = # Ax + By = C
  var a, b: Point
  if eq(A, 0.0): a = initPoint(0.0, C / B); b = initPoint(1, C / B)
  elif eq(B, 0): b = initPoint(C / A, 0); b = initPoint(C / A, 1)
  else: a = initPoint(0, C / B); b = initPoint(C / A, 0)
  return initLine(a, b)

#  friend ostream &operator<<(ostream &os, Line &p) {
#    return os << p.a << " to " << p.b;
#  }
#
#  friend istream &operator>>(istream &is, Line &a) {
#    return is >> a.a >> a.b;
#  }
#};

type Segment = Line

proc initSegment(a, b:Point):Segment = Segment(a:a, b:b)
#struct Segment : Line {
#  Segment() = default;
#
#  Segment(Point a, Point b) : Line(a, b) {}
#};

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

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_A
proc projection(l:Line, p:Point):Point =
  let t = dot(p - l.a, l.a - l.b) / norm(l.a - l.b)
  return l.a + (l.a - l.b) * t

proc projection(l:Segment, p:Point):Point =
  let t = dot(p - l.a, l.a - l.b) / norm(l.a - l.b)
  return l.a + (l.a - l.b) * t

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_B
proc reflection(l:Line, p:Point):Point = return p + (projection(l, p) - p) * 2.0

proc intersect(l:Line, p:Point):bool = abs(ccw(l.a, l.b, p)) != 1
proc intersect(l,m: Line):bool = abs(cross(l.b - l.a, m.b - m.a)) > EPS or abs(cross(l.b - l.a, m.b - l.a)) < EPS

proc intersect(s:Segment, p:Point):bool = ccw(s.a, s.b, p) == 0

proc intersect(l:Line, s:Segment):bool = cross(l.b - l.a, s.a - l.a) * cross(l.b - l.a, s.b - l.a) < EPS

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

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_A&lang=jp
proc intersect(c1, c2: Circle):int =
  var (c1, c2) = (c1, c2)
  if c1.r < c2.r: swap(c1, c2)
  let d = abs(c1.p - c2.p)
  if c1.r + c2.r < d: return 4
  if eq(c1.r + c2.r, d): return 3
  if c1.r - c2.r < d: return 2
  if eq(c1.r - c2.r, d): return 1
  return 0

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
  return min(distance(a, b.a), distance(a, b.b), distance(b, a.a), distance(b, a.b))

proc distance(l:Line, s:Segment):Real =
  if intersect(l, s): return 0
  return min(distance(l, s.a), distance(l, s.b));

proc crosspoint(l,m:Line):Point =
  let
    A = cross(l.b - l.a, m.b - m.a)
    B = cross(l.b - l.a, l.b - m.a)
  if(eq(abs(A), 0.0) and eq(abs(B), 0.0)) return m.a;
  return m.a + (m.b - m.a) * B / A;
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_C
Point crosspoint(const Segment &l, const Segment &m) {
  return crosspoint(Line(l), Line(m));
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_D
pair< Point, Point > crosspoint(const Circle &c, const Line l) {
  Point pr = projection(l, c.p);
  Point e = (l.b - l.a) / abs(l.b - l.a);
  if(eq(distance(l, c.p), c.r)) return {pr, pr};
  double base = sqrt(c.r * c.r - norm(pr - c.p));
  return {pr - e * base, pr + e * base};
}

pair< Point, Point > crosspoint(const Circle &c, const Segment &l) {
  Line aa = Line(l.a, l.b);
  if(intersect(c, l) == 2) return crosspoint(c, aa);
  auto ret = crosspoint(c, aa);
  if(dot(l.a - ret.first, l.b - ret.first) < 0) ret.second = ret.first;
  else ret.first = ret.second;
  return ret;
}

# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_E
pair< Point, Point > crosspoint(const Circle &c1, const Circle &c2) {
  Real d = abs(c1.p - c2.p);
  Real a = arccos((c1.r * c1.r + d * d - c2.r * c2.r) / (2 * c1.r * d));
  Real t = arctan2(c2.p.im - c1.p.im, c2.p.re - c1.p.re);
  Point p1 = c1.p + Point(cos(t + a) * c1.r, sin(t + a) * c1.r);
  Point p2 = c1.p + Point(cos(t - a) * c1.r, sin(t - a) * c1.r);
  return {p1, p2};
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_F
// tangent of circle c through point p
pair< Point, Point > tangent(const Circle &c1, const Point &p2) {
  return crosspoint(c1, Circle(p2, sqrt(norm(c1.p - p2) - c1.r * c1.r)));
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_G
// common tangent of circles c1 and c2
Lines tangent(Circle c1, Circle c2) {
  Lines ret;
  if(c1.r < c2.r) swap(c1, c2);
  Real g = norm(c1.p - c2.p);
  if(eq(g, 0)) return ret;
  Point u = (c2.p - c1.p) / sqrt(g);
  Point v = rotate(PI * 0.5, u);
  for(int s : {-1, 1}) {
    Real h = (c1.r + s * c2.r) / sqrt(g);
    if(eq(1 - h * h, 0)) {
      ret.emplace_back(c1.p + u * c1.r, c1.p + (u + v) * c1.r);
    } else if(1 - h * h > 0) {
      Point uu = u * h, vv = v * sqrt(1 - h * h);
      ret.emplace_back(c1.p + (uu + vv) * c1.r, c2.p - (uu + vv) * c2.r * s);
      ret.emplace_back(c1.p + (uu - vv) * c1.r, c2.p - (uu - vv) * c2.r * s);
    }
  }
  return ret;
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_3_B
bool is_convex(const Polygon &p) {
  int n = (int) p.size();
  for(int i = 0; i < n; i++) {
    if(ccw(p[(i + n - 1) % n], p[i], p[(i + 1) % n]) == -1) return false;
  }
  return true;
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_4_A
Polygon convex_hull(Polygon &p) {
  int n = (int) p.size(), k = 0;
  if(n <= 2) return p;
  sort(p.begin(), p.end());
  vector< Point > ch(2 * n);
  for(int i = 0; i < n; ch[k++] = p[i++]) {
    while(k >= 2 and cross(ch[k - 1] - ch[k - 2], p[i] - ch[k - 1]) < EPS) --k;
  }
  for(int i = n - 2, t = k + 1; i >= 0; ch[k++] = p[i--]) {
    while(k >= t and cross(ch[k - 1] - ch[k - 2], p[i] - ch[k - 1]) < EPS) --k;
  }
  ch.resize(k - 1);
  return ch;
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_3_C
enum {
  OUT, ON, IN
};

int contains(const Polygon &Q, const Point &p) {
  bool in = false;
  for(int i = 0; i < Q.size(); i++) {
    Point a = Q[i] - p, b = Q[(i + 1) % Q.size()] - p;
    if(a.im > b.im) swap(a, b);
    if(a.im <= 0 and 0 < b.im and cross(a, b) < 0) in = !in;
    if(cross(a, b) == 0 and dot(a, b) <= 0) return ON;
  }
  return in ? IN : OUT;
}


// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=1033
// deduplication of line segments
void merge_segments(vector< Segment > &segs) {

  auto merge_if_able = [](Segment &s1, const Segment &s2) {
    if(abs(cross(s1.b - s1.a, s2.b - s2.a)) > EPS) return false;
    if(ccw(s1.a, s2.a, s1.b) == 1 or ccw(s1.a, s2.a, s1.b) == -1) return false;
    if(ccw(s1.a, s1.b, s2.a) == -2 or ccw(s2.a, s2.b, s1.a) == -2) return false;
    s1 = Segment(min(s1.a, s2.a), max(s1.b, s2.b));
    return true;
  };

  for(int i = 0; i < segs.size(); i++) {
    if(segs[i].b < segs[i].a) swap(segs[i].a, segs[i].b);
  }
  for(int i = 0; i < segs.size(); i++) {
    for(int j = i + 1; j < segs.size(); j++) {
      if(merge_if_able(segs[i], segs[j])) {
        segs[j--] = segs.back(), segs.pop_back();
      }
    }
  }
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=1033
// construct a graph with the vertex of the intersection of any two line segments
vector< vector< int > > segment_arrangement(vector< Segment > &segs, vector< Point > &ps) {
  vector< vector< int > > g;
  int N = (int) segs.size();
  for(int i = 0; i < N; i++) {
    ps.emplace_back(segs[i].a);
    ps.emplace_back(segs[i].b);
    for(int j = i + 1; j < N; j++) {
      const Point p1 = segs[i].b - segs[i].a;
      const Point p2 = segs[j].b - segs[j].a;
      if(cross(p1, p2) == 0) continue;
      if(intersect(segs[i], segs[j])) {
        ps.emplace_back(crosspoint(segs[i], segs[j]));
      }
    }
  }
  sort(begin(ps), end(ps));
  ps.erase(unique(begin(ps), end(ps)), end(ps));

  int M = (int) ps.size();
  g.resize(M);
  for(int i = 0; i < N; i++) {
    vector< int > vec;
    for(int j = 0; j < M; j++) {
      if(intersect(segs[i], ps[j])) {
        vec.emplace_back(j);
      }
    }
    for(int j = 1; j < vec.size(); j++) {
      g[vec[j - 1]].push_back(vec[j]);
      g[vec[j]].push_back(vec[j - 1]);
    }
  }
  return (g);
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_4_C
// cut with a straight line l and return a convex polygon on the left
Polygon convex_cut(const Polygon &U, Line l) {
  Polygon ret;
  for(int i = 0; i < U.size(); i++) {
    Point now = U[i], nxt = U[(i + 1) % U.size()];
    if(ccw(l.a, l.b, now) != -1) ret.push_back(now);
    if(ccw(l.a, l.b, now) * ccw(l.a, l.b, nxt) < 0) {
      ret.push_back(crosspoint(Line(now, nxt), l));
    }
  }
  return (ret);
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_3_A
Real area(const Polygon &p) {
  Real A = 0;
  for(int i = 0; i < p.size(); ++i) {
    A += cross(p[i], p[(i + 1) % p.size()]);
  }
  return A * 0.5;
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_H
Real area(const Polygon &p, const Circle &c) {
  if(p.size() < 3) return 0.0;
  function< Real(Circle, Point, Point) > cross_area = [&](const Circle &c, const Point &a, const Point &b) {
    Point va = c.p - a, vb = c.p - b;
    Real f = cross(va, vb), ret = 0.0;
    if(eq(f, 0.0)) return ret;
    if(max(abs(va), abs(vb)) < c.r + EPS) return f;
    if(distance(Segment(a, b), c.p) > c.r - EPS) return c.r * c.r * arg(vb * conj(va));
    auto u = crosspoint(c, Segment(a, b));
    vector< Point > tot{a, u.first, u.second, b};
    for(int i = 0; i + 1 < tot.size(); i++) {
      ret += cross_area(c, tot[i], tot[i + 1]);
    }
    return ret;
  };
  Real A = 0;
  for(int i = 0; i < p.size(); i++) {
    A += cross_area(c, p[i], p[(i + 1) % p.size()]);
  }
  return A;
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_4_B
Real convex_diameter(const Polygon &p) {
  int N = (int) p.size();
  int is = 0, js = 0;
  for(int i = 1; i < N; i++) {
    if(p[i].im > p[is].im) is = i;
    if(p[i].im < p[js].im) js = i;
  }
  Real maxdis = norm(p[is] - p[js]);

  int maxi, maxj, i, j;
  i = maxi = is;
  j = maxj = js;
  do {
    if(cross(p[(i + 1) % N] - p[i], p[(j + 1) % N] - p[j]) >= 0) {
      j = (j + 1) % N;
    } else {
      i = (i + 1) % N;
    }
    if(norm(p[i] - p[j]) > maxdis) {
      maxdis = norm(p[i] - p[j]);
      maxi = i;
      maxj = j;
    }
  } while(i != is or j != js);
  return sqrt(maxdis);
}

// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_5_A
Real closest_pair(Points ps) {
  if(ps.size() <= 1) throw (0);
  sort(begin(ps), end(ps));

  auto compare_y = [&](const Point &a, const Point &b) {
    return imag(a) < imag(b);
  };
  vector< Point > beet(ps.size());
  const Real INF = 1e18;

  function< Real(int, int) > rec = [&](int left, int right) {
    if(right - left <= 1) return INF;
    int mid = (left + right) >> 1;
    auto x = real(ps[mid]);
    auto ret = min(rec(left, mid), rec(mid, right));
    inplace_merge(begin(ps) + left, begin(ps) + mid, begin(ps) + right, compare_y);
    int ptr = 0;
    for(int i = left; i < right; i++) {
      if(abs(real(ps[i]) - x) >= ret) continue;
      for(int j = 0; j < ptr; j++) {
        auto luz = ps[i] - beet[ptr - j - 1];
        if(imag(luz) >= ret) break;
        ret = min(ret, abs(luz));
      }
      beet[ptr++] = ps[i];
    }
    return ret;
  };
  return rec(0, (int) ps.size());
}
