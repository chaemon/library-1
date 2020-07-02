# TwoSat(v:int) {{{
type TwoSat = object
  sz:int
  g:Graph[int]
  comp:seq[int]

proc initTwoSat(v:int):auto =
  return TwoSat(sz:v, g:initGraph[int](v + v))

proc rev(self:TwoSat, x:int):auto =
  if x >= self.sz: return x - self.sz
  else: return x + self.sz

proc addLiteral(self: var TwoSat, u,v:int) =
  self.g.addEdge(self.rev(u), v)
  self.g.addEdge(self.rev(v), u)

proc addLiteral(self: var TwoSat, u:int) =
  self.g.addEdge(u, u)

proc solve(self: var TwoSat):bool =
  self.comp = stronglyConnectedComponents(self.g)[0]
  for i in 0..<self.sz:
    if self.comp[i] == self.comp[self.rev(i)]: return false
  return true

proc `[]`(self: var TwoSat, v:int):bool =
  return self.comp[v] > self.comp[self.rev(v)]
# }}}
