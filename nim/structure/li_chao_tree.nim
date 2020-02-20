# LiChaoTree {{{
type
  Line[T] = object
    a, b:T
  LiChaoTree[T] = object
    sz: int
    xs: seq[T]
    seg: seq[Line[T]]

proc initLine[T](a, b:T):Line[T] = Line[T](a:a, b:b)
proc get[T](self: Line[T], x:T):T = self.a * x + self.b
proc over[T](self, b: Line[T], x: T):bool = self.get(x) < b.get(x)

proc initLiChaoTree[T](x: seq[T], INF:T):LiChaoTree[T] =
  var xs = x
  var sz = 1
  while sz < xs.len: sz = sz shl 1
  while xs.len < sz: xs.add(xs[^1] + 1)
  return LiChaoTree[T](sz:sz, xs:xs, seg:newSeqWith(2 * sz - 1, initLine(0, INF)))

#proc update[T](self: var LiChaoTree[T], x:Line[T], k, l, r:int) =
#  let
#    mid = (l + r) shr 1
#    latte = x.over(self.seg[k], self.xs[l])
#    malta = x.over(self.seg[k], self.xs[mid])
#  var x = x
#  if malta: swap(self.seg[k], x)
#  if l + 1 >= r: return
#  elif latte != malta: self.update(x, 2 * k + 1, l, mid)
#  else: self.update(x, 2 * k + 2, mid, r)

proc disjoint(x, y:Slice[int]):bool = x.b < y.a or y.b < x.a
proc subset(x, y:Slice[int]):bool = y.a <= x.a and x.b <= y.b

proc update[T](self: var LiChaoTree[T], x:Line[T], s:Slice[int], k:int, ks:Slice[int]) =
  if disjoint(s, ks): return
  let (l, r) = (ks.a, ks.b + 1)
  let m = (l + r + 1) shr 1
  if not subset(ks, s):
    self.update(x, s, 2 * k + 1, l..<m)
    self.update(x, s, 2 * k + 2, m..<r)
  else:
    let
      latte = x.over(self.seg[k], self.xs[l])
      malta = x.over(self.seg[k], self.xs[m])
    var x = x
    if malta: swap(self.seg[k], x)
    if l + 1 >= r: return
    elif latte != malta: self.update(x, s, 2 * k + 1, l..<m)
    else: self.update(x, s, 2 * k + 2, m..<r)

proc update[T](self: var LiChaoTree[T], a, b:T, s:Slice[int]) =
  let l = initLine(a, b)
  self.update(l, s, 0, 0..<self.sz)
proc update[T](self: var LiChaoTree[T], a, b:T) =
  let l = initLine(a, b)
  self.update(l, 0..<self.sz, 0, 0..<self.sz)

proc query[T](self: var LiChaoTree[T], k:int):T =
  let x = self.xs[k]
  var k = k + self.sz - 1;
  result = self.seg[k].get(x)
  while k > 0:
    k = (k - 1) shr 1
    result = min(result, self.seg[k].get(x))
# }}}
