proc warshall_floyd(dist: seq[seq[int]]): seq[seq[int]] =
  let N = dist.len
  var dist = dist
  for k in 0..<N:
    for i in 0..<N:
      for j in 0..<N:
        if dist[i][k] == int.infty or dist[k][j] == int.infty: continue
        let d = dist[i][k] + dist[k][j]
        if dist[i][j] > d: dist[i][j] = d
  return dist
