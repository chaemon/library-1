type
  flow_edge[flow_t] = object
    src,dst,rev,idx:int
    cap:flow_t
    isrev:bool
  FordFulkerson[flow_t] = object
    graph: seq[seq[flow_edge[flow_t]]]
    used: seq[int]
    inf: flow_t
    timestamp: int

proc newFordFulkerson[flow_t](n:int): FordFulkerson[flow_t] =
  return FordFulkerson[flow_t](graph:newSeq[seq[flow_edge[flow_t]]](n), used:newSeqWith(n,-1), inf:flow_t.infty, timestamp:0)

proc addEdge[flow_t](self:var FordFulkerson[flow_t], src, dst:int, cap:flow_t, idx = -1) =
  self.graph[src].add(flow_edge[flow_t](src:src, dst:dst, cap:cap, rev:self.graph[dst].len, isrev:false, idx:idx))
  self.graph[dst].add(flow_edge[flow_t](src:dst, dst:src, cap:0, rev:self.graph[src].len - 1, isrev:true, idx:idx))

proc dfs[flow_t](self: var FordFulkerson[flow_t], idx, t:int, flow:flow_t):flow_t =
  if idx == t: return flow
  self.used[idx] = self.timestamp
  for e in self.graph[idx].mitems:
    if e.cap > 0 and self.used[e.dst] != self.timestamp:
      let d = self.dfs(e.dst, t, min(flow, e.cap))
      if d > 0:
        e.cap -= d
        self.graph[e.dst][e.rev].cap += d
        return d
  return 0

proc maxFlow[flow_t](self: var FordFulkerson[flow_t], s,t:int):flow_t =
  var flow = flow_t(0)
  while true:
    let f = self.dfs(s, t, self.inf)
    if f == 0: break
    flow += f
    self.timestamp += 1
  return flow

proc output[flow_t](self: FordFulkerson[flow_t]) =
  for i in 0..<self.graph.len:
    for e in self.graph[i]:
      if e.isrev: continue
      let rev_e = self.graph[e.dst][e.rev]
      echo i, "->", e.dst, " (flow: ", rev_e.cap, "/", e.cap + rev_e.cap, ")"
