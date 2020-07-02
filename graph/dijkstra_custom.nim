# custom dijkustra template {{{

let dir:array[4, tuple[x,y:int]] = [(0,1),(1,0),(0,-1),(-1,0)]

import strformat
#import deques
import heapqueue

macro `[]`(a: untyped, p: tuple): untyped =
  var strBody = fmt"{a.repr}"
  for i, _ in p.getTypeImpl: strBody &= fmt"[{p.repr}[{i}]]"
  parseStmt(strBody)
macro `[]=`(a: untyped, p: tuple, x: untyped): untyped =
  var strBody = fmt"{a.repr}"
  for i, _ in p.getTypeImpl: strBody &= fmt"[{p.repr}[{i}]]"
  strBody &= fmt" = {x.repr}"
  parseStmt(strBody)

proc dijkstra_custom():auto =
  type P = tuple[x, y, dir:int]
  type S = tuple[p:P, d:int]

  proc `<`(l,r:S):bool = l.d < r.d

  var
    dist = Seq(H, W, 4, int.inf)
    vis = Seq(H, W, 4, false)
    Q = initHeapQueue[S]()

  proc set_push(p:P, d:int) =
    if vis[p]: return
    if dist[p] <= d: return
    dist[p] = d
    Q.push((p, d))

  # initial
  for i in 0..<4:
    let p:P = (x1,y1,i)
    set_push(p, 0)

  # iteration

  while Q.len > 0:
    let (p, d) = Q.pop()
    if vis[p]: continue
    vis[p] = true
    # definition
    let (x, y, di) = p
    # next
    block:
      let
        x2 = x + dir[di].x
        y2 = y + dir[di].y
      if x2 in 0..<H and y2 in 0..<W and c[x2][y2] != '@':
        set_push((x2, y2, di), d + 1)
    for di2 in 0..<4:
      if di2 == di: continue
      let d2 = ((d + K - 1) div K) * K
      set_push((x,y,di2), d2)
  # answer
  var ans = int.inf
  
  for p in 0..<4:
    let d = dist[(x2,y2,p)]
    if d == int.inf: continue
    ans.min=(d + K - 1) div K

  return ans
# }}}
