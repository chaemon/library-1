#{{{ LazySegmentTree[Monoid, OperatorMonoid](n,f,g,h,M1,OM0)

type LazySegmentTree[Monoid, OperatorMonoid] = object
  sz, height: int
  f: (Monoid, Monoid)->Monoid
  g: (Monoid, OperatorMonoid) -> Monoid
  h: (OperatorMonoid, OperatorMonoid) -> OperatorMonoid
  data: seq[Monoid]
  lazy: seq[OperatorMonoid]
  M1: Monoid
  OM0: OperatorMonoid

proc newLazySegmentTree[Monoid, OperatorMonoid](n: int, f: (Monoid, Monoid)->Monoid, g: (Monoid, OperatorMonoid)->Monoid, h:(OperatorMonoid, OperatorMonoid)->OperatorMonoid, M1: Monoid, OM0: OperatorMonoid): LazySegmentTree[Monoid, OperatorMonoid] =
  var
    sz = 1
    height = 0
  while sz < n: sz *= 2;height += 1
  var
    data = newSeqWith(sz * 2, M1)
    lazy = newSeqWith(sz * 2, OM0)
  return LazySegmentTree[Monoid, OperatorMonoid](sz:sz, height:height, f:f, g:g, h:h, data:data, lazy:lazy, M1:M1, OM0:OM0)

proc set[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid,OperatorMonoid], k:int, x:Monoid) =
  self.data[k + self.sz] = x

proc build[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid,OperatorMonoid], v:seq[Monoid]) =
  var v = v
  while v.len < self.sz: v.add(self.M1)
  for i in 0..<self.sz:
    self.data[i + self.sz] = v[i]
  for k in countdown(self.sz - 1, 1):
    self.data[k] = self.f(self.data[2*k], self.data[2*k+1])

proc reflect[Monoid, OperatorMonoid](self:LazySegmentTree[Monoid, OperatorMonoid], k:int):Monoid =
  if self.lazy[k] == self.OM0:
    return self.data[k]
  else:
    return self.g(self.data[k], self.lazy[k])

proc propagate[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid, OperatorMonoid], k:int) =
  if self.lazy[k] != self.OM0:
    self.lazy[2 * k + 0] = self.h(self.lazy[2 * k + 0], self.lazy[k])
    self.lazy[2 * k + 1] = self.h(self.lazy[2 * k + 1], self.lazy[k])
    self.data[k] = self.reflect(k)
    self.lazy[k] = self.OM0

proc recalc[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid, OperatorMonoid], k:int) =
  var k = k div 2
  while k > 0:
    self.data[k] = self.f(self.reflect(2 * k + 0), self.reflect(2 * k + 1))
    k = k div 2

proc thrust[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid, OperatorMonoid], k:int) =
  for i in countdown(self.height, 1):
    self.propagate(k shr i)

proc update[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid, OperatorMonoid], a,b:int, x:OperatorMonoid) =
  let
    a = a + self.sz
    b = b + self.sz - 1
  self.thrust(a)
  self.thrust(b)
  var
    l = a
    r = b + 1
  while l < r:
    if (l and 1) > 0: self.lazy[l] = self.h(self.lazy[l], x);l += 1
    if (r and 1) > 0: r -= 1;self.lazy[r] = self.h(self.lazy[r], x)
    l = (l shr 1);r = (r shr 1)
  self.recalc(a);
  self.recalc(b);

proc query[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid, OperatorMonoid], a,b:int):Monoid =
  let
    a = a + self.sz
    b = b + self.sz - 1
  self.thrust(a)
  self.thrust(b)
  var
    L = self.M1
    R = self.M1
    l = a
    r = b + 1
  while l < r:
    if (l and 1) > 0: L = self.f(L, self.reflect(l));l += 1
    if (r and 1) > 0: r -= 1;R = self.f(self.reflect(r), R)
    l = l shr 1;r = r shr 1
  return self.f(L, R);

proc `[]`[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid, OperatorMonoid], k:int):Monoid =
  return self.query(k, k + 1)

proc findSubtree[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid, OperatorMonoid], a:int, check:proc(a:Monoid):bool, M:var Monoid, t:int):int =
  var a = a
  while a < self.sz:
    self.propagate(a)
    let nxt = if t != 0: self.f(self.reflect(2 * a + t), M) else: self.f(M, self.reflect(2 * a + t))
    if check(nxt): a = 2 * a + t
    else: M = nxt;a = 2 * a + 1 - t
  return a - self.sz

proc findFirst[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid, OperatorMonoid], a:int, check:proc(a:Monoid):bool):int =
  var
    L = self.M1
    a = a
  if a <= 0:
    if check(self.f(L, self.reflect(1))): return self.find_subtree(1, check, L, 0)
    return -1
  self.thrust(a + self.sz)
  var b = self.sz
  a += self.sz
  b += self.sz
  while a < b:
    if (a and 1) > 0:
      let nxt = self.f(L, self.reflect(a))
      if check(nxt): return self.find_subtree(a, check, L, 0)
      L = nxt
      a += 1
    a = a shr 1
    b = b shr 1
  return -1;

proc findLast[Monoid, OperatorMonoid](self: var LazySegmentTree[Monoid, OperatorMonoid], b:int, check:proc(a:Monoid):bool):int =
  var
    R = self.M1
    b = b
  if b >= self.sz:
    if check(self.f(self.reflect(1), R)): return self.find_subtree(1, check, R, 1)
    return -1
  self.thrust(b + self.sz - 1)
  var a = self.sz
  b += self.sz
  while a < b:
    if (b and 1) > 0:
      b -= 1
      let nxt = self.f(self.reflect(b), R)
      if check(nxt): return self.find_subtree(b, check, R, 1)
      R = nxt;
    a = a shr 1
    b = b shr 1
  return -1


proc output[Monoid, OperatorMonoid](self: LazySegmentTree[Monoid, OperatorMonoid]) =

  var s = 1
  for h in 0..self.height:
    for i in s..<s*2: stdout.write self.data[i],"/",self.lazy[i], " - "
    echo ""
    s *= 2

#}}}
