#ReRooting: initReRooting[Weight, Data](n:int, f_up(Data,Weight)->Data, f_merge:(Data,Data)->Data, ident:Data)
# {{{
import sequtils, future
type
  Node[Weight] = object
    to, rev: int
    data: Weight
  ReRooting[Weight, Data] = object
    g:seq[seq[Node[Weight]]]
    ldp, rdp: seq[seq[Data]]
    lptr, rptr: seq[int]
    ident: Data
    f_up: (Data,Weight)->Data
    f_merge: (Data,Data)->Data

proc initNode[Weight](to, rev:int, d: Weight):Node[Weight] = Node[Weight](to: to, rev: rev, data: d)
proc initReRooting[Weight, Data](n:int, f_up:(Data,Weight)->Data, f_merge:(Data,Data)->Data, ident:Data):ReRooting[Weight,Data] =
  return ReRooting[Weight,Data](
    g:newSeqWith(n, newSeq[Node[Weight]]()),
    ldp:newSeqWith(n, newSeq[Data]()),
    rdp:newSeqWith(n, newSeq[Data]()),
    lptr:newSeq[int](n), rptr:newSeq[int](n),
    f_up:f_up, f_merge:f_merge, ident:ident)

proc addEdge[Weight, Data](self: var ReRooting[Weight, Data]; u,v:int, d:Weight) =
  self.g[u].add(initNode[Weight](v, self.g[v].len, d))
  self.g[v].add(initNode[Weight](u, self.g[u].len - 1, d))
proc addEdgeBi[Weight, Data](self: var ReRooting[Weight, Data]; u,v:int, d,e:Weight) =
  self.g[u].add(initNode[Weight](v, self.g[v].len, d))
  self.g[v].add(initNode[Weight](u, self.g[u].len - 1, e))
proc dfs[Weight, Data](self: var ReRooting[Weight, Data], idx, par:int):Data =
  while self.lptr[idx] != par and self.lptr[idx] < self.g[idx].len:
    var e = self.g[idx][self.lptr[idx]].addr
    self.ldp[idx][self.lptr[idx] + 1] = self.f_merge(self.ldp[idx][self.lptr[idx]], self.f_up(self.dfs(e[].to, e[].rev), e[].data))
    self.lptr[idx] += 1
  while self.rptr[idx] != par and self.rptr[idx] >= 0:
    var e = self.g[idx][self.rptr[idx]].addr
    self.rdp[idx][self.rptr[idx]] = self.f_merge(self.rdp[idx][self.rptr[idx] + 1], self.f_up(self.dfs(e[].to, e[].rev), e[].data))
    self.rptr[idx] -= 1
  if par < 0: return self.rdp[idx][0]
  return self.f_merge(self.ldp[idx][par], self.rdp[idx][par + 1])

proc solve[Weight, Data](self: var ReRooting[Weight, Data]):seq[Data] =
  for i in 0..<self.g.len:
    self.ldp[i] = newSeqWith(self.g[i].len + 1, self.ident)
    self.rdp[i] = newSeqWith(self.g[i].len + 1, self.ident)
    self.lptr[i] = 0
    self.rptr[i] = self.g[i].len - 1
  result = newSeq[Data]()
  for i in 0..<self.g.len: result.add(self.dfs(i, -1))
#}}}
