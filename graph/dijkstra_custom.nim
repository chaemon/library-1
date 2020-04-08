type S = object
  x, y, u: int
  d: int
 
proc `<`(a,b:S):auto = a.d < b.d

var
  dist = newSeqWith(H, W, U, int.inf)
  vis = newSeqWith(H, W, U, false)
  Q = initHeapQueue[S]()
dist[0][0][0] = 0
Q.push(S(x:0, y:0, d:0))
while Q.len > 0:
  var e = Q.pop()
  let (x, y, u, d) = (e.x, e.y, e.u, e.d)
  if vis[x][y][u]: continue
  vis[x][y][u] = true
  if x == H - 1 and y == W - 1:
    print d
    break
  for p in dir4:
    let (x2, y2) = (x + p.x, y + p.y)
    if x2 notin 0..<H or y2 notin 0..<W: continue
    let d2 = d + (u * 2 + 1) * A[x2][y2]
    let u2 = u + 1
    if u2 >= U: continue
    if dist[x2][y2][u2] > d2:
      dist[x2][y2][u2] = d2
      Q.push(S(x:x2, y:y2, u:u2, d:d2))
