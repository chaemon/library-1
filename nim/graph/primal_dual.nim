include "../standard_library/heapqueue.nim"

type
  PrimalDual[flow_t, cost_t] = object
    graph: seq[seq[flow_edge[flow_t, cost_t]]]
    potential, min_cost:seq[cost_t]
    prevv, preve:seq[int]
    Inf: cost_t
  flow_edge[flow_t, cost_t] = object
    dst:int
    cap:flow_t
    cost:cost_t
    rev:int
    isrev:bool

proc initPrimalDual[flow_t, cost_t](V:int):PrimalDual[flow_t, cost_t] =
  return PrimalDual[flow_t, cost_t](graph: newSeqWith(V,newSeq[flow_edge[flow_t, cost_t]]()), Inf: cost_t.infty, potential: newSeqWith(V,0), preve:newSeqWith(V,-1),prevv:newSeqWith(V,-1))

proc addEdge[flow_t, cost_t](self: var PrimalDual[flow_t, cost_t], src, dst:int, cap:flow_t, cost:cost_t) =
  self.graph[src].add(flow_edge[flow_t, cost_t](dst:dst, cap:cap, cost:cost, rev:self.graph[dst].len, isrev:false))
  self.graph[dst].add(flow_edge[flow_t, cost_t](dst:src, cap:0, cost: -cost, rev:self.graph[src].len - 1, isrev:true))

proc minCostFlow[flow_t, cost_t](self: var PrimalDual[flow_t, cost_t], s,t:int, f:flow_t):cost_t =
  let V = self.graph.len
  var ret = cost_t(0)
  type Pi = (cost_t, int)
  var que = initHeapQueue[Pi]()
  var f = f

  while f > 0:
    self.min_cost = newSeqWith(V, self.Inf)
    que.push((0, s))
    self.min_cost[s] = 0
    while que.len > 0:
      let p = que.pop()
      if self.min_cost[p[1]] < p[0]: continue
      for i in 0..<self.graph[p[1]].len:
        let e = self.graph[p[1]][i]
        let nextCost = self.min_cost[p[1]] + e.cost + self.potential[p[1]] - self.potential[e.dst]
        if e.cap > 0 and self.min_cost[e.dst] > nextCost:
          self.min_cost[e.dst] = nextCost
          self.prevv[e.dst] = p[1]; self.preve[e.dst] = i
          que.push((self.min_cost[e.dst], e.dst))
    if self.min_cost[t] == self.Inf: return -1
    for v in 0..<V:self.potential[v] += self.min_cost[v]
    var addflow = flow_t(f)
    var v = t
    while v != s:
      addflow = min(addflow, self.graph[self.prevv[v]][self.preve[v]].cap)
      v = self.prevv[v]
    f -= addflow;
    ret += addflow * self.potential[t]
    v = t
    while v != s:
      let e = self.graph[self.prevv[v]][self.preve[v]]
#      e[].cap -= addflow
      self.graph[self.prevv[v]][self.preve[v]].cap -= addflow
      self.graph[v][e.rev].cap += addflow
      v = self.prevv[v]
  return ret

proc output[flow_t, cost_t](self:PrimalDual[flow_t, cost_t]) =
  for i in 0..<self.graph.len:
    for e in self.graph[i]:
      if e.isrev: continue
      let rev_e = self.graph[e.dst][e.rev];
      echo i , "->" , e.dst , " (flow: " , rev_e.cap , "/" , rev_e.cap + e.cap , ")"

