import sequtils

type MinimumSpanningTreeArborescence[T] = object
  es:seq[Edge[T]]
  V:int

proc initMinimumSpanningTreeArborescence[T](es:Edges[T], V:int):MinimumSpanningTreeArborescence[T] =
  return MinimumSpanningTreeArborescence[T](es:es, V:V)

proc build[T](self: var MinimumSpanningTreeArborescence[T], start:int):T =
  let
    g = (a:(T,int), b:T) => (a[0] + b, a[1])
    h = (a:T, b:T) => a + b
  var heap = initSkewHeap[(T,int), int](g, h)
  var heaps = newSeqWith(self.V, heap.makeheap())
  for e in self.es: heap.push(heaps[e.dst], (e.weight, e.src))
  var
    uf = initUnionFind(self.V)
    used = newSeqWith(self.V, -1)
  used[start] = start

  var ret = T(0)
  for s in 0..<self.V:
    var path = newSeq[int]()
    var u = s
    while used[u] < 0:
      path.add(u)
      used[u] = s
      if heap.empty(heaps[u]): return -1
      let p = heap.top(heaps[u])
      ret += p[0]
      heap.add(heaps[u], -p[0])
      heap.pop(heaps[u])
      let v = uf.root(p[1])
      if used[v] == s:
        var w:int
        var nextheap = heap.makeheap()
        while true:
          w = path.pop()
          nextheap = heap.merge(nextheap, heaps[w]);
          if not uf.unionSet(v, w): break
        heaps[uf.root(v)] = nextheap
        used[uf.root(v)] = -1
      u = uf.root(v);
  return ret;

