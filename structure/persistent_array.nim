const LOG = 3

# Persistent Array {{{
type
  Node[T] = ref object
    data:T
    child:array[1 shl LOG, Node[T]]
  PersistentArray[T] = object
    root: Node[T]

proc build[T](t:var Node[T], data:T, k:int):Node[T] =
  if t == nil: t = Node[T]()
  if k == 0:
    t.data = data
    return t
  let p = build(t.child[k and ((1 shl LOG) - 1)], data, k shr LOG)
  t.child[k and ((1 shl LOG) - 1)] = p
  return t

proc build[T](self:var PersistentArray[T], v:seq[T]) =
  self.root = nil
  for i in 0..<v.len:
    self.root = self.root.build(v[i], i)

proc initPersistentArray[T](v:seq[T]):auto =
  result = PersistentArray[T]()
  result.build(v)

proc `[]`[T](t:Node[T], k:int):auto =
  if k == 0: return t.data
  return t.child[k and ((1 shl LOG) - 1)][k shr LOG]

proc `[]`[T](self:PersistentArray[T], k:int):auto = return self.root[k]

proc `[]=`[T](t:var Node[T], k:int, val:T):Node[T] {.discardable.}=
  t = if t != nil: Node[T](data:t.data, child:t.child) else: Node[T]()
  if k == 0:
    t.data = val
    return t
  var p = (t.child[k and ((1 shl LOG) - 1)][k shr LOG] = val)
  t.child[k and ((1 shl LOG) - 1)] = p
  return t

proc `[]=`[T](self:var PersistentArray[T], k:int, val:T) =
  var ret = (self.root[k] = val)
  self.root = ret
# }}}
