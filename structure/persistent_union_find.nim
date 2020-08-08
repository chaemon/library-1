# PersistentUnionFind {{{
type PersistentUnionFind = object
  data: PersistentArray[int]

proc initPersistentUnionFind(sz:int):PersistentUnionFind =
  PersistentUnionFind(data:initPersistentArray[int](newSeqWith(sz, -1)))

proc find(self:PersistentUnionFind, k:int):int =
  let p = self.data[k]
  return if p >= 0: self.find(p) else: k

proc size(self:PersistentUnionFind, k:int):int = -self.data[self.find(k)]

proc union(self:PersistentUnionFind, x, y:int):PersistentUnionFind =
  let
    x = self.find(x)
    y = self.find(y)
  if x == y: return self
  var self = self
  let
    u = self.data[x]
    v = self.data[y]
  if u < v:
    self.data[x] = u + v
    self.data[y] = x
  else:
    self.data[y] = u + v
    self.data[x] = y
  return self
# }}}

let N, Q = nextInt()
var
  uf = initPersistentUnionFind(N)
  G = newSeq[PersistentUnionFind](Q+1)
G[0] = uf

for i in 0..<Q:
  var t, k, u, v = nextInt()
  k.inc
  if t == 0:
    G[i+1] = G[k].union(u, v)
  else:
    echo if G[k].find(u) == G[k].find(v): 1 else: 0
