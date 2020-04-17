import sugar

# DynamicDualSegmentTree {{{
type Node[D] = object
  v:D
#  left, right:Node[D]
  li, ri:int

#var ndi = 0
#var nds:array[3 * 10^6, Node[int]]

type DynamicSegmentTree[D] = object
  n, n0:int
#  root:Node[D]
  ri:int
  f:(D,D)->D
  D0:D

proc newNode[D](v:D):Node[D] = Node[D](v:v, left:nil, right: nil)
#proc newNodeid[D](v:D):int =
#  nds[ndi].v = v
#  nds[ndi].li = -1
#  nds[ndi].ri = -1
#  ndi += 1
#  return ndi - 1
#  Node[D](v:v, left:nil, right: nil)

proc initDynamicDualSegmentTree[D](n:int, f:(D,D)->D, D0:D):DynamicSegmentTree[D] =
  ndi = 0
  var n0 = 1
  while n0 < n: n0 *= 2
#  var root = newNode[D](D0)
  var ri = newNodeid[D](D0)
  return DynamicSegmentTree[D](n:n, n0:n0, ri:ri, f:f, D0:D0)

proc push[D](self: var DynamicSegmentTree[D]; ni:int) =
  if nds[ni].v == self.D0: return
  else:
    nds[nds[ni].li].v = self.f(nds[nds[ni].li].v, nds[ni].v)
    nds[nds[ni].ri].v = self.f(nds[nds[ni].ri].v, nds[ni].v)

proc update[D](self: var DynamicSegmentTree[D]; s:Slice[int], ni:int, p:Slice[int], x:D) =
  if s.a <= p.a and p.b <= s.b: nds[ni].v = self.f(nds[ni].v, x);return
  elif s.b < p.a or p.b < s.a: return
  let m = (p.a + p.b + 1) shr 1
  if nds[ni].li == -1: nds[ni].li = newNodeid(self.D0)
  if nds[ni].ri == -1: nds[ni].ri = newNodeid(self.D0)
  self.push(ni)
  self.update(s, nds[ni].li, p.a..<m, x)
  self.update(s, nds[ni].ri, m..p.b, x)

proc `[]`[D](self: DynamicSegmentTree[D]; k:int):D =
  result = self.D0
  var
    ni = self.ri
    (l, r) = (0, self.n0)
  while ni != -1:
    result = self.f(result, nds[ni].v)
    if r - l == 1: break
    let m = (l + r) shr 1
    if k < m: r = m;ni = nds[ni].li
    else: l = m;ni = nds[ni].ri

proc update[D](self: var DynamicSegmentTree[D]; s:Slice[int], x:D) = self.update(s, self.ri, 0..<self.n0, x)
proc lupdate[D](self: var DynamicSegmentTree[D]; b:int, x:D) = self.update(0..<b, self.ri, 0..<self.n0, x)
proc rupdate[D](self: var DynamicSegmentTree[D]; a:int, x:D) = self.update(a..<self.n0, self.ri, 0..<self.n0, x)
# }}}
