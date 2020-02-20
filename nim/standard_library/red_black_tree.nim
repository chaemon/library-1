#{{{ redBlackTree[K,V](cmp), insert, remove find, lowerBound
type
  Color = enum red, black
  Node[K, V] = ref object
    parent: Node[K, V]
    left, right: Node[K, V]
    key: K
    value: V
    color: Color
    id: int
  RedBlackTree*[K, V] = object of RootObj
    greater: proc(a,b:K):bool
    leaf,root,End: Node[K, V]
    size: int
    multi: bool
    cmp: proc(a:K,node:Node[K,V]):int
    next_id: int
  OrderedSet[K] = object of RedBlackTree[K, int]
  OrderedMap[K, V] = object of RedBlackTree[K, V]

proc get_cmp[K,V](self: RedBlackTree[K, V], greater:proc(a,b:K):bool):proc (a:K, node:Node[K,V]):int =
  let End = self.End
  return proc(a:K, node:Node[K,V]):int = 
    if node == End or greater(a, node.key): -1
    elif a > node.key: 1
    else: 0
proc newNode[K, V](self: var RedBlackTree[K, V], parent: Node[K, V], key: K, value: V): Node[K, V] =
  result = Node[K, V](parent: parent, left: self.leaf, right: self.leaf, key: key, value: value, color: Color.red, id: self.next_id)
  self.next_id += 1

proc initRedBlackTree*[K, V](greater: proc(a,b:K):bool, multi:bool): RedBlackTree[K, V] =
  let leaf = Node[K, V](color: Color.black)
  leaf.left = leaf;leaf.right = leaf
  let End = Node[K, V](color: Color.black)
  End.left = leaf;End.right = leaf
  result = RedBlackTree[K, V](leaf: leaf, End: End, root: End, multi: multi, greater: greater, next_id: 0)
  result.cmp = result.get_cmp(greater)

proc greater[K](a,b:K):bool = a < b

proc initOrderedSet*[K](multi:bool = false): OrderedSet[K] = 
  let leaf = Node[K, int](color: Color.black)
  leaf.left = leaf;leaf.right = leaf
  let End = Node[K, int](color: Color.black)
  End.left = leaf;End.right = leaf
  result = OrderedSet[K](leaf: leaf, End: End, root: End, multi: multi, greater: greater, next_id: 0)
  result.cmp = result.get_cmp(greater)
proc initOrderedMultiSet*[K](): OrderedSet[K] = initOrderedSet[K](true)
proc initOrderedMap*[K,V](multi:bool = false): OrderedMap[K,V] = 
  let leaf = Node[K, V](color: Color.black)
  leaf.left = leaf;leaf.right = leaf
  let End = Node[K, V](color: Color.black)
  End.left = leaf;End.right = leaf
  result = OrderedMap[K, V](leaf: leaf, End: End, root: End, multi: multi, greater: greater, next_id: 0)
  result.cmp = result.get_cmp(greater)

proc initOrderedMultiMap*[K,V](): OrderedMap[K,V] = initOrderedMap[K, V](true)

proc isLeaf[K,V](self: Node[K,V]):bool = self.left == self

proc leftMost[K,V](self: Node[K, V]): Node[K, V] =
  if self.left.isLeaf: return self
  else: return self.left.leftMost
proc rightMost[K,V](self: Node[K, V]): Node[K, V] =
  if self.right.isLeaf: return self
  else: return self.right.rightMost
proc parentLeft[K,V](node: Node[K, V]): Node[K, V] =
  var node = node
  while true:
    if node.parent == nil: return nil
    elif node.parent.left == node: return node.parent
    node = node.parent
proc parentRight[K,V](node: Node[K, V]): Node[K, V] =
  var node = node
  while true:
    if node.parent == nil: return nil
    elif node.parent.right == node: return node.parent
    node = node.parent
proc front[K,V](self: RedBlackTree[K, V]): Node[K, V] =
  return self.root.leftMost
proc tail[K,V](self: RedBlackTree[K, V]): Node[K, V] =
  return self.root.rightMost

proc succ[K, V](node: Node[K, V]): Node[K, V] =
  if not node.right.isLeaf: return node.right.leftMost
  else: return node.parentLeft
proc pred[K, V](node: Node[K, V]): Node[K, V] =
  if not node.left.isLeaf: return node.left.rightMost
  else: return node.parentRight

#{{{ rotate founctions
proc rotateLeft[K, V](self: var RedBlackTree[K, V], parent: Node[K, V]) =
  if parent == nil: return
  var right = parent.right
  parent.right = right.left
  if right.left != nil: right.left.parent = parent
  right.parent = parent.parent
  if parent.parent == nil: self.root = right
  elif parent.parent.left == parent: parent.parent.left = right
  else: parent.parent.right = right
  right.left = parent
  parent.parent = right

proc rotateRight[K, V](self: var RedBlackTree[K, V], parent: Node[K, V]) =
  if parent == nil: return
  var left = parent.left
  parent.left = left.right
  if left.right != nil: left.right.parent = parent
  left.parent = parent.parent
  if parent.parent == nil: self.root = left
  elif parent.parent.right == parent: parent.parent.right = left
  else: parent.parent.left = left
  left.right = parent
  parent.parent = left
#}}}

# insert {{{
proc fixInsert[K, V](self: var RedBlackTree[K, V], node: Node[K, V]) =
  ## Rebalances a tree after an insertion
  var curr = node
  while curr != self.root and curr.parent.color == Color.red:
    if curr.parent.parent != nil and curr.parent == curr.parent.parent.left:
      var uncle = curr.parent.parent.right
      if uncle.color == Color.red:
        curr.parent.color = Color.black
        uncle.color = Color.black
        curr.parent.parent.color = Color.red
        curr = curr.parent.parent
      else:
        if curr == curr.parent.right:
          curr = curr.parent
          self.rotateLeft(curr)
        curr.parent.color = Color.black
        if curr.parent.parent != nil:
          curr.parent.parent.color = Color.red
          self.rotateRight(curr.parent.parent)
    elif curr.parent.parent != nil:
      var uncle = curr.parent.parent.left
      if uncle.color == Color.red:
        curr.parent.color = Color.black
        uncle.color = Color.black
        curr.parent.parent.color = Color.red
        curr = curr.parent.parent
      else:
        if curr == curr.parent.left:
          curr = curr.parent
          self.rotateRight(curr)
        curr.parent.color = Color.black
        if curr.parent.parent != nil:
          curr.parent.parent.color = Color.red
          self.rotateLeft(curr.parent.parent)
  self.root.color = Color.black

proc insert*[K, V](self: var RedBlackTree[K, V], node: var Node[K, V]): Node[K, V] {.discardable.} =
  if self.root == nil:
    node.parent = nil
    self.root = node
    self.size += 1
    self.fixInsert(self.root)
    return node

  # Otherwise find the insertion point
  var curr = self.root
  while not curr.isLeaf:
    var comp = self.cmp(node.key, curr)
    if self.multi and comp == 0:
      comp = 1
    if comp == 0:
      # If it's already there, set the data and return
      curr.value = node.value
      return nil
    elif comp < 0:
      # Goes to the left
      if curr.left.isLeaf:
        # Nothing there, insert here
        node.parent = curr
        curr.left = node
        self.size += 1
        self.fixInsert(curr.left)
        return node
      curr = curr.left
    else:
      # Goes to the right
      if curr.right.isLeaf:
        # Nothing there, insert here
        node.parent = curr
        curr.right = node
        self.size += 1
        self.fixInsert(curr.right)
        return node
      curr = curr.right
  return nil

proc insert*[K, V](self: var RedBlackTree[K, V], key: K, value: V): Node[K, V] {.discardable.} =
  var node = self.newNode(nil, key, value)
  return self.insert(node)

proc insert*[K](self: var OrderedSet[K], key: K): Node[K, int] {.discardable.} =
  return self.insert(key, 0)
# }}}

# find {{{
proc findNode[K, V](self: RedBlackTree[K, V], key: K): Node[K, V] =
  var curr = self.root
  while not curr.isLeaf:
    let comp = self.cmp(key, curr)
    if comp == 0: return curr
    elif comp < 0: curr = curr.left
    else: curr = curr.right
  return nil

proc find*[K, V](self: RedBlackTree[K, V], key: K): (V, bool) =
  let node = self.findNode(key)
  if node != nil:
    return (node.value, true)
  var default: V
  return (default, false)

proc contains*[K, V](self: RedBlackTree[K, V], key: K):bool = self.find(key)[1]

proc `[]`[K, V](self: var OrderedMap[K, V], key: K): var V =
  var node = self.findNode(key)
  if node == nil: node = self.insert(key, V(0))
  return self.findNode(key).value

#{{{ lowerBound and upperBound
proc lowerBound[K, V](self: RedBlackTree[K, V], curr: Node[K,V], key: K): Node[K,V] =
  if curr.isLeaf: return nil
  if curr != self.End and self.greater(curr.key, key):
    return self.lowerBound(curr.right,key)
  else:
    let lb = self.lowerBound(curr.left,key)
    if lb == nil: return curr
    else: return lb

proc lowerBound[K, V](self: RedBlackTree[K, V], key: K): Node[K,V] =
  let t = self.lowerBound(self.root,key)
  if t == nil: return self.End
  else: return t

proc upperBound[K, V](self: RedBlackTree[K, V], curr: Node[K,V], key: K): Node[K,V] =
  if curr.isLeaf: return nil
  if curr == self.End or self.greater(key, curr.key):
    let ub = self.upperBound(curr.left,key)
    if ub == nil: return curr
    else: return ub
  else:
    return self.upperBound(curr.right,key)

proc upperBound[K, V](self: RedBlackTree[K, V], key: K): Node[K,V] =
  let t = self.upperBound(self.root,key)
  if t == nil: return self.End
  else: return t
#}}}
# }}}

# remove {{{
proc fixRemove[K, V](self: var RedBlackTree[K, V], node: Node[K, V], parent: Node[K, V]) =
  var
    child = node
    parent = parent
  while child != self.root and child.color == Color.black:
    if child == parent.left:
      var sib = parent.right
      if sib.color == Color.red:
        sib.color = Color.black
        parent.color = Color.red
        self.rotateLeft(parent)
        sib = parent.right

      if sib.left.color == Color.black and sib.right.color == Color.black:
        sib.color = Color.red
        child = parent
        parent = child.parent
      else:
        if sib.right.color == Color.black:
          sib.left.color = Color.black
          sib.color = Color.red
          self.rotateRight(sib)
          sib = parent.right
        sib.color = parent.color
        parent.color = Color.black
        sib.right.color = Color.black
        self.rotateLeft(parent)
        child = self.root
        parent = child.parent
    else:
      var sib = parent.left
      if sib.color == Color.red:
        sib.color = Color.black
        parent.color = Color.red
        self.rotateRight(parent)
        sib = parent.left

      if sib.right.color == Color.black and sib.left.color == Color.black:
        sib.color = Color.red
        child = parent
        parent = child.parent
      else:
        if sib.left.color == Color.black:
          sib.right.color = Color.black
          sib.color = Color.red
          self.rotateLeft(sib)
          sib = parent.left
        sib.color = parent.color
        parent.color = Color.black
        sib.left.color = Color.black
        self.rotateRight(parent)
        child = self.root
        parent = child.parent
  child.color = Color.black

proc remove*[K, V](self: var RedBlackTree[K, V], node: Node[K,V]) =
  var node = node

  self.size -= 1
  if not node.left.isLeaf and not node.right.isLeaf:
    let pred = node.pred
    node.key = pred.key
    node.value = pred.value
    node = pred

  let child = if not node.left.isLeaf: node.left else: node.right
  if not child.isLeaf:
    child.parent = node.parent
    if node.parent == nil:
      self.root = child
    elif node == node.parent.left:
      node.parent.left = child
    else:
      node.parent.right = child
    if node.color == Color.black:
      self.fixRemove(child, node.parent)
  else:
    if node.parent == nil:
      self.root = self.leaf
    elif node == node.parent.left:
      node.parent.left = self.leaf
    else:
      assert node == node.parent.right
      node.parent.right = self.leaf
    if node.color == Color.black:
      self.fixRemove(self.leaf, node.parent)

proc remove*[K, V](self: var RedBlackTree[K, V], key: K): bool {.discardable.} =
  var node = self.findNode(key)
  if node == nil: return false
  self.remove(node)
  return true
# }}}

proc len*[K, V](self: RedBlackTree[K, V]): int =
  return self.size

iterator iterOrder*[K, V](self: RedBlackTree[K, V]): (K, V) =
  var node = self.root
  var stack: seq[Node[K, V]] = @[]
  while stack.len() != 0 or not node.isLeaf:
    if not node.isLeaf:
      stack.add(node)
      node = node.left
    else:
      node = stack.pop()
      if node == self.End: break
      yield (node.key, node.value)
      node = node.right
proc `$`[K](self: OrderedSet[K]): string =
  result = "[ "
  var node = self.root
  var stack: seq[Node[K, int]] = @[]
  while stack.len() != 0 or not node.isLeaf:
    if not node.isLeaf:
      stack.add(node)
      node = node.left
    else:
      node = stack.pop()
      result &= $(node.key) & " "
      node = node.right
  result &= "]"
proc `$`[K,V](self: OrderedMap[K, V]): string =
  result = "[ "
  var node = self.root
  var stack: seq[Node[K, V]] = @[]
  while stack.len() != 0 or not node.isLeaf:
    if not node.isLeaf:
      stack.add(node)
      node = node.left
    else:
      node = stack.pop()
      result &= $(node.key) & ": " & $(node.value) & " "
      node = node.right
  result &= "]"

proc write[K,V](self: Node[K, V], h = 0) =
  for i in 0..<h: stderr.write " | "
  if self.isLeaf:
    stderr.write "*\n"
  else:
    if self.key == int.inf: stderr.write "inf"
    else: stderr.write self.key
    stderr.write " ", self.value, " ", self.color, " ", self.t, "\n"
    if h >= 15:
      stderr.write "too deep!!!\n"
      assert false
      return
    self.left.write(h + 1)
    self.right.write(h + 1)
proc write[K,V](self: RedBlackTree[K, V]) =
  stderr.write "======= RB-TREE =============\n"
  self.root.write(0)
  stderr.write "======= END ==========\n"
#}}}
