type
  Node[T, E] = ref object
    key:T
    lazy:E
    l, r:Node[T,E]
  SkewHeap[T,E] = object
    rev:bool
    g:(T, E)->T
    h:(E, E)->E
 
proc newSkewHeap[T,E](rev = false):SkewHeap[T,E] =
  return SkewHeap[T,E](rev:rev, g:(a:T, b:E)=>a+b, h:(a:E,b:E)=>a+b)
  
proc newSkewHeap[T,E](g:(T,E)->T, h:(E,E)->E, rev = false): SkewHeap[T,E] =
  return SkewHeap[T,E](rev:rev, g:g, h:h)

proc propagate[T,E](self:SkewHeap[T,E], t:Node[T,E]):Node[T,E] {.discardable.} =
  if t.lazy != 0:
    if t.l != nil: t.l.lazy = self.h(t.l.lazy, t.lazy)
    if t.r != nil: t.r.lazy = self.h(t.r.lazy, t.lazy)
    t.key = self.g(t.key, t.lazy)
    t.lazy = 0
  return t

proc merge[T,E](self:SkewHeap[T,E], x, y:Node[T,E]):Node[T,E] =
  if x == nil: return y
  if y == nil: return x
  var
    x = x
    y = y
  self.propagate(x);self.propagate(y)
  if (x.key > y.key) xor self.rev: swap(x, y)
  x.r = self.merge(y, x.r)
  swap(x.l, x.r)
  return x

proc push[T,E](self: SkewHeap[T,E], root: var Node[T, E], key:T) =
  root = self.merge(root, Node[T,E](key:key, lazy:0, l:nil, r:nil))

proc top[T,E](self: SkewHeap[T,E], root:Node[T,E]):T = self.propagate(root).key

proc pop[T,E](self: SkewHeap[T,E], root:var Node[T,E]):T {.discardable.}=
  let top = self.propagate(root).key
  var temp = root
  root = self.merge(root.l, root.r)
  return top

proc empty[T,E](self: SkewHeap[T,E], root:Node[T,E]):bool = (root == nil)

proc add[T,E](self:SkewHeap[T,E], root:Node[T,E], lazy:E) =
  if root != nil:
    root.lazy = self.h(root.lazy, lazy)
    self.propagate(root)

proc makeheap[T,E](self:SkewHeap[T,E]):Node[T,E] = nil
