type DualSegmentTree[OperatorMonoid] = object
  sz, height: int
  lazy: seq[OperatorMonoid]
  h: (OperatorMonoid, OperatorMonoid) -> OperatorMonoid
  OM0: OperatorMonoid

proc initDualSegmentTree[OperatorMonoid](n:int, h:(OperatorMonoid,OperatorMonoid)->OperatorMonoid, OM0:OperatorMonoid):DualSegmentTree[OperatorMonoid] =
  var
    sz = 1
    height = 0
  while sz < n: sz *= 2;height+=1
  return DualSegmentTree[OperatorMonoid](sz:sz, height:height, lazy:newSeqWith(2*sz, OM0), h:h, OM0:OM0)

proc propagate[OperatorMonoid](self: var DualSegmentTree[OperatorMonoid], k:int) =
  if self.lazy[k] != self.OM0:
    self.lazy[2 * k + 0] = self.h(self.lazy[2 * k + 0], self.lazy[k])
    self.lazy[2 * k + 1] = self.h(self.lazy[2 * k + 1], self.lazy[k])
    self.lazy[k] = self.OM0

proc thrust[OperatorMonoid](self: var DualSegmentTree[OperatorMonoid], k:int) =
  for i in countdown(self.height,1): self.propagate(k shr i)

proc update[OperatorMonoid](self: var DualSegmentTree[OperatorMonoid], p:Slice[int], x:OperatorMonoid) =
  var
    a = p.a + self.sz
    b = p.b + self.sz
  self.thrust(a)
  self.thrust(b)
  var
    l = a
    r = b + 1
  while l < r:
    if(l and 1) > 0: self.lazy[l] = self.h(self.lazy[l], x); l+=1
    if(r and 1) > 0: r-=1; self.lazy[r] = self.h(self.lazy[r], x)
    l = (l shr 1)
    r = (r shr 1)

proc `[]`[OperatorMonoid](self:var DualSegmentTree[OperatorMonoid], k:int):OperatorMonoid =
  var k = k + self.sz
  self.thrust(k)
  return self.lazy[k]
