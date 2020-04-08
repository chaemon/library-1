#{{{ gridBfs
type S = object
  cost: int
  x, y:int

proc `<`(s,t:S):bool = s.cost < t.cost

proc gridBfs(s:openarray[string], start:char, X:int):seq[seq[int]] =
  let (R, C) = (s.len, s[0].len)
  proc inner(x, y:int):bool = (0 <= x and x < R and 0 <= y and y < C)
  let
    vx = [0,1, 0,-1]
    vy = [1,0,-1, 0]
  var min_cost = newSeqWith(R, newSeqWith(C, -1))
  var que = initHeapQueue[S]()
  for i in 0..<R:
    for j in 0..<C:
      if s[i][j] == start:
        que.push(S(cost:0, x:i, y:j))
        min_cost[i][j] = 0
  while que.len > 0:
    let p = que.pop
    for i in 0..<vx.len:
      let
        nx = p.x + vx[i]
        ny = p.y + vy[i]
      if not inner(nx, ny): continue
      if min_cost[nx][ny] != -1: continue
      if s[nx][ny] == '#':
        min_cost[nx][ny] = min_cost[p.x][p.y] + X
        que.push(S(cost: min_cost[nx][ny], x:nx, y:ny))
      else:
        min_cost[nx][ny] = min_cost[p.x][p.y] + 1
        que.push(S(cost: min_cost[nx][ny], x:nx, y:ny))
  return min_cost
#}}}
