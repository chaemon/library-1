import sequtils

type BipartiteMatching = object
  graph: seq[seq[int]]
  match, alive, used: seq[int]
  timestamp: int

proc newBipartiteMatching(n:int): BipartiteMatching =
  return BipartiteMatching(graph:newSeq[seq[int]](n), alive: newSeqWith(n, 1), used:newSeqWith(n, 0), match:newSeqWith(n, -1), timestamp:0)

proc addEdge(self:var BipartiteMatching, u,v:int) =
  self.graph[u].add(v)
  self.graph[v].add(u)

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

proc bipartite_matching(self: var BipartiteMatching):int =
  var ret = 0
  for i in 0..<self.graph.len:
    if self.alive[i] == 0: continue
    if self.match[i] == -1:
      self.timestamp += 1
      ret += self.dfs(i)
  return ret

proc output(self: BipartiteMatching) =
  for i in 0..<self.graph.len:
    if i < self.match[i]:
      echo i, "-", self.match[i]
