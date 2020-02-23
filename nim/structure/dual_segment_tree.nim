# DualSegmentTree {{{
type DualSegmentTree[L] = object
  sz, height: int
  lazy: seq[L]
  h: (L, L) -> L
  L0: L

proc initDualSegmentTree[L](n:int, h:(L,L)->L, L0:L):DualSegmentTree[L] =
  var
    sz = 1
    height = 0
  while sz < n: sz *= 2;height+=1
  return DualSegmentTree[L](sz:sz, height:height, lazy:newSeqWith(2*sz, L0), h:h, L0:L0)

proc propagate[L](self: var DualSegmentTree[L], k:int) =
  if self.lazy[k] != self.L0:
    self.lazy[2 * k + 0] = self.h(self.lazy[2 * k + 0], self.lazy[k])
    self.lazy[2 * k + 1] = self.h(self.lazy[2 * k + 1], self.lazy[k])
    self.lazy[k] = self.L0

proc thrust[L](self: var DualSegmentTree[L], k:int) =
  for i in countdown(self.height,1): self.propagate(k shr i)

proc update[L](self: var DualSegmentTree[L], p:Slice[int], x:L) =
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

proc `[]`[L](self:var DualSegmentTree[L], k:int):L =
  var k = k + self.sz
  self.thrust(k)
  return self.lazy[k]
# }}}
