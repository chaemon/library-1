# DynamicSegmentTree[D](n:int, f:(D,D)->D, D0:D){{{
type Node[D] = ref object
  v:D
  left, right:Node[D]

type DynamicSegmentTree[D] = object
  n, n0:int
  root:Node[D]
  f:(D,D)->D
  D0:D

proc newNode[D](v:D):Node[D] = Node[D](v:v, left:nil, right: nil)

proc initDynamicSegmentTree[D](n:int, f:(D,D)->D, D0:D):DynamicSegmentTree[D] =
  var n0 = 1
  while n0 < n: n0 *= 2
  var root = newNode[D](D0)
  return DynamicSegmentTree[D](n:n, n0:n0, root:root, f:f, D0:D0)

proc query[D](self: DynamicSegmentTree[D]; a,b:int, n:Node, l,r:int):D =
  if a <= l and r <= b: return n.v
  elif r <= a or b <= l: return self.D0
  let
    lv = if n.left != nil: self.query(a, b, n.left, l, (l + r) shr 1) else: self.D0
    rv = if n.right != nil: self.query(a, b, n.right, (l + r) shr 1, r) else: self.D0
  return self.f(lv, rv)

proc update[D](self: var DynamicSegmentTree[D]; k,x:int) =
  var
    n = self.root
    (l, r) = (0, self.n0)
  n.v = self.f(n.v, x)
  while r - l > 1:
    let m = (l + r) shr 1
    if k < m:
      if n.left == nil: n.left = newNode(self.D0)
      n = n.left
      r = m
    else:
      if n.right == nil: n.right = newNode(self.D0)
      n = n.right
      l = m
    n.v = self.f(n.v, x)

proc query[D](self: DynamicSegmentTree[D]; a,b:int):D = self.query(a, b, self.root, 0, self.n0)
proc lquery[D](self: DynamicSegmentTree[D]; b:int):D = self.query(0, b, self.root, 0, self.n0)
proc rquery[D](self: DynamicSegmentTree[D]; a;int):D = return query(a, self.n0, self.root, 0, self.n0)
# }}}
