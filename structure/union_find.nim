#{{{ Union-Find
type UnionFind = object
  data:seq[int]

proc initUnionFind(size:int):UnionFind =
  var uf:UnionFind
  uf.data = newSeqWith(size,-1)
  return uf

proc compress(uf:var UnionFind,x:int,r:var int):void =
  if uf.data[x]<0:
    r = x
    return
  uf.compress(uf.data[x],r)
  uf.data[x] = r;

proc root(uf:var UnionFind, x:int):int =
  var r:int
  uf.compress(x,r)
  return r;

proc size(uf:var UnionFind, x:int):int =
  return -uf.data[uf.root(x)]

proc unionSet(uf:var UnionFind, x,y:int):bool{.discardable.} =
  var
    rx = uf.root(x)
    ry = uf.root(y)
  if rx == ry: return false
  if uf.data[ry] < uf.data[rx]:
    swap(rx, ry)
  uf.data[rx] += uf.data[ry]
  uf.data[ry] = rx
  return true

proc findSet(uf:var UnionFind, x,y:int):bool =
  return uf.root(x) != uf.root(y)
#}}}
