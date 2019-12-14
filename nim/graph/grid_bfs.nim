#{{{ gridBfs
proc gridBfs(s:openarray[string], start:char, wall = "#"):seq[seq[int]] =
  let (R, C) = (s.len, s[0].len)
  proc inner(x, y:int):bool = (0 <= x and x < R and 0 <= y and y < C)
  let
    vx = [0,1, 0,-1]
    vy = [1,0,-1, 0]
  var min_cost = newSeqWith(R, newSeqWith(C, -1))
  var que = initDeque[(int,int)]()
  for i in 0..<R:
    for j in 0..<C:
      if s[i][j] == start:
        que.addLast((i,j))
        min_cost[i][j] = 0
  while que.len > 0:
    let p = que.popFirst()
    for i in 0..<vx.len:
      let
        nx = p[0] + vx[i]
        ny = p[1] + vy[i]
      if not inner(nx, ny): continue
      if min_cost[nx][ny] != -1: continue
      if wall.find(s[nx][ny]) != -1: continue
      min_cost[nx][ny] = min_cost[p[0]][p[1]] + 1
      que.addLast((nx, ny))
  return min_cost
#}}}
