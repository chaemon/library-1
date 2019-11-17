when (not (NimMajor <= 0) or NimMinor >= 19):
  import deques
else:
  include "../standard_library/deque.nim"

type
  flow_edge[flow_t] = object
    dst, rev, idx:int
    cap:flow_t
    isrev:bool
  PushRelabel[flow_t] = object
    graph:seq[seq[flow_edge[flow_t]]]
    ex:seq[flow_t]
    relabels, high:int
    cnt, h:seq[int]
    hs:seq[seq[int]]
    Inf:flow_t

proc newPushRelabel[flow_t](V:int):PushRelabel[flow_t] =
  return PushRelabel[flow_t](graph:newSeqWith(V, newSeq[flow_edge[flow_t]]()), Inf:flow_t.infty, hs:newSeqWith(V + 1,newSeq[int]()), high:0)

proc addEdge[flow_t](self:var PushRelabel[flow_t], src, dst:int, cap:flow_t, idx = -1) =
  self.graph[src].add(flow_edge[flow_t](dst:dst, cap:cap, rev:self.graph[dst].len, isrev:false, idx:idx))
  self.graph[dst].add(flow_edge[flow_t](dst:src, cap:0, rev:self.graph[src].len - 1, isrev:true, idx:idx))

proc updateHeight[flow_t](self: var PushRelabel[flow_t], idx,nxt_height:int) =
  self.relabels += 1
  if self.h[idx] != self.graph.len + 1: self.cnt[self.h[idx]] -= 1
  self.h[idx] = nxt_height
  if self.h[idx] != self.graph.len + 1:
    self.high = nxt_height
    self.cnt[nxt_height] += 1
    if self.ex[idx] > 0: self.hs[nxt_height].add(idx)

proc globalRelabel[flow_t](self:var PushRelabel[flow_t], idx:int) =
  for i in 0..self.high: self.hs[i].setlen(0)
  self.relabels = 0;
  self.high = 0;
  self.h = newSeqWith(self.graph.len, self.graph.len + 1)
  self.cnt = newSeqWith(self.graph.len, 0)
  var que = initDeque[int]()
  que.addLast(idx)
  self.h[idx] = 0;
  while que.len > 0:
    let p = que.popFirst()
    for e in self.graph[p]:
      if self.h[e.dst] == self.graph.len + 1 and self.graph[e.dst][e.rev].cap > 0:
        que.addLast(e.dst)
        self.high = self.h[p] + 1
        self.updateHeight(e.dst, self.high)

#proc push[flow_t](self:var PushRelabel[flow_t], idx:int, e: var flow_edge[flow_t]) =
proc push[flow_t](self:var PushRelabel[flow_t], idx:int, id:int) =
  let e = self.graph[idx][id]
  if self.h[e.dst] == self.graph.len + 1: return
  if self.ex[e.dst] == 0: self.hs[self.h[e.dst]].add(e.dst)
  let df = min(self.ex[idx], e.cap)

#  e.cap -= df
  self.graph[idx][id].cap -= df

  self.graph[e.dst][e.rev].cap += df
  self.ex[idx] -= df
  self.ex[e.dst] += df

proc discharge[flow_t](self:var PushRelabel[flow_t], idx:int) =
  var next_height =  self.graph.len + 1
#  for e in self.graph[idx].mitems:
  for i in 0..<self.graph[idx].len:
    let e = self.graph[idx][i]
    if e.cap > 0:
      if self.h[idx] == self.h[e.dst] + 1:
        self.push(idx, i)
        if self.ex[idx] <= 0: return
      else:
        next_height = min(next_height, self.h[e.dst] + 1)
  if self.cnt[self.h[idx]] > 1:
    self.updateHeight(idx, next_height)
  else:
    while self.high >= self.h[idx]:
      for j in self.hs[self.high]: self.updateHeight(j, self.graph.len + 1)
      self.hs[self.high].setLen(0)
      self.high -= 1

proc maxFlow[flow_t](self:var PushRelabel[flow_t], s,t:int):flow_t =
  self.ex = newSeqWith(self.graph.len, 0)
  self.ex[s] = self.Inf
  self.ex[t] = - self.Inf
  self.globalRelabel(t)
#  for e in self.graph[s].mitems: self.push(s, e)
  for i in 0..<self.graph[s].len: self.push(s, i)
  while self.high >= 0:
    while self.hs[self.high].len > 0:
      let idx = self.hs[self.high].pop()
      self.discharge(idx)
      if self.relabels >= self.graph.len * 4: self.globalRelabel(t)
    self.high -= 1
  return self.ex[t] + self.Inf

proc output[flow_t](self:PushRelabel[flow_t]) =
  for i in 0..<self.graph.len:
    for e in self.graph[i]:
      if e.isrev: continue
      let rev_e = self.graph[e.dst][e.rev]
      echo i, "->" , e.dst , " (flow: " , rev_e.cap , "/" , e.cap + rev_e.cap , ")"
