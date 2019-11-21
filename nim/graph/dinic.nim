when (not (NimMajor <= 0) or NimMinor >= 19):
  import deques
else:
  include "../standard_library/deque.nim"

type 
  flow_edge[flow_t] = object
    dst, rev, idx:int
    cap:flow_t
    isrev:bool
  Dinic[flow_t] = object
    graph:seq[seq[flow_edge[flow_t]]]
    min_cost, iter: seq[int]
    Inf: flow_t

proc initDinic[flow_t](V:int): Dinic[flow_t] = Dinic[flow_t](graph:newSeqWith(V,newSeq[flow_edge[flow_t]]()), Inf:flow_t.infty)

proc addEdge[flow_t](self: var Dinic[flow_t], src, dst:int, cap:flow_t, idx = -1) =
  self.graph[src].add(flow_edge[flow_t](dst:dst, cap:cap, rev:self.graph[dst].len, isrev:false, idx:idx))
  self.graph[dst].add(flow_edge[flow_t](dst:src, cap:flow_t(0), rev:self.graph[src].len - 1, isrev:true, idx:idx))

proc bfs[flow_t](self:var Dinic[flow_t], s,t:int):bool =
  self.min_cost = newSeqWith(self.graph.len, -1)
  var que = initDeque[int]()
  self.min_cost[s] = 0
  que.addLast(s)
  while que.len > 0 and self.min_cost[t] == -1:
    let p = que.popFirst()
    for e in self.graph[p]:
      if e.cap > 0 and self.min_cost[e.dst] == -1:
        self.min_cost[e.dst] = self.min_cost[p] + 1
        que.addLast(e.dst)
  return self.min_cost[t] != -1

proc dfs[flow_t](self:var Dinic[flow_t], idx, t:int, flow:flow_t):flow_t =
  if idx == t: return flow
  while self.iter[idx] < self.graph[idx].len:
    let e = self.graph[idx][self.iter[idx]]
    if e.cap > 0 and self.min_cost[idx] < self.min_cost[e.dst]:
      let d = self.dfs(e.dst, t, min(flow, e.cap))
      if d > 0:
#        e.cap -= d
        self.graph[idx][self.iter[idx]].cap -= d
        self.graph[e.dst][e.rev].cap += d
        return d
    self.iter[idx] += 1
  return flow_t(0)

proc maxFlow[flow_t](self:var Dinic[flow_t], s,t:int):flow_t =
  var flow = flow_t(0)
  while self.bfs(s, t):
    self.iter = newSeqWith(self.graph.len, 0)
    var f = flow_t(0)
    while true:
      f = self.dfs(s,t,self.Inf)
      if f == 0: break
      flow += f
  return flow

proc output[flow_t](self:Dinic[flow_t]) =
  for i in 0..<self.graph.len:
    for e in self.graph[i]:
      if e.isrev: continue
      let rev_e = self.graph[e.to][e.rev]
      echo i, "->", e.dst, " (flow: ", rev_e.cap, "/", e.cap + rev_e.cap, ")"
