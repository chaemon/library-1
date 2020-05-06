import sequtils

type BipartiteMatching = object
  n, m:int
  graph: seq[seq[int]]
  match, alive, used: seq[int]
  timestamp: int

proc initBipartiteMatching(n, m:int): BipartiteMatching =
  return BipartiteMatching(n:n, m:m, graph:newSeqWith(n + m,newSeq[int]()), alive: newSeqWith(n + m, 1), used:newSeqWith(n + m, 0), match:newSeqWith(n + m, -1), timestamp:0)

proc addEdge(self:var BipartiteMatching, u,v:int) =
  self.graph[u].add(v + self.n)
  self.graph[v + self.n].add(u)

proc bipartite_matching(self: var BipartiteMatching):seq[(int,int)] =
  # dfs function {{{
  proc dfs(self:var BipartiteMatching, idx:int):int =
    self.used[idx] = self.timestamp
    for dst in self.graph[idx]:
      let to_match = self.match[dst]
      if self.alive[dst] == 0: continue
      if to_match == -1 or (self.used[to_match] != self.timestamp and self.dfs(to_match) == 1):
        self.match[idx] = dst
        self.match[dst] = idx
        return 1
    return 0
  # }}}
  var ret = 0
  for i in 0..<self.graph.len:
    if self.alive[i] == 0: continue
    if self.match[i] == -1:
      self.timestamp += 1
      ret += self.dfs(i)
  result = newSeq[(int,int)]()
  for i in 0..<self.graph.len:
    let m = self.match[i]
    if i < m: result.add((i,m - self.n))

proc output(self: BipartiteMatching) =
  for i in 0..<self.graph.len:
    if i < self.match[i]:
      echo i, "-", self.match[i]
