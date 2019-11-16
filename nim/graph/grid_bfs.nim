import deques,sequtils

proc gridBfs(s:openarray[string], start:char, wall = "#"):seq[seq[int]] =
  let
    vx = [0,1, 0,-1]
    vy = [1,0,-1, 0]
  var min_cost = newSeqWith(s.len, newSeqWith(s[0].len, -1))
  var que = initDeque[(int,int)]()
  for i in 0..<s.len:
    for j in 0..<s[0].len:
      if s[i][j] == start:
        que.addLast((i,j))
        min_cost[i][j] = 0
  while que.len > 0:
    let p = que.popFirst()
    for i in 0..<vx.len:
      let
        ny = p[0] + vy[i]
        nx = p[1] + vx[i]
      if nx < 0 or ny < 0 or nx >= s[0].len or ny >= s.len: continue
      if min_cost[ny][nx] != -1: continue
      if wall.find(s[ny][nx]) != -1: continue
      min_cost[ny][nx] = min_cost[p[0]][p[1]] + 1
      que.addLast((ny, nx))
  return min_cost
