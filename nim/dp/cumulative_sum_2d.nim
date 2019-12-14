type CumulativeSum2D[T] = object
  data: seq[seq[T]]

proc initCumulativeSum2D[T](W, H:int):CumulativeSum2D[T] = CumulativeSum2D(data: newSeqWith(W + 1, newSeqWith(H + 1, T(0))))

proc add[T](self:var CumulativeSum2D[T]; x, y:int, z:T) =
  var (x, y) = (x + 1, y + 1)
  if x >= self.data.len or y >= self.data[0].len: return
  self.data[x][y] += z

proc build[T](self:var CumulativeSum2D[T]) =
  for i in 0..<self.data.len:
    for j in 0..<self.data[i].len:
      self.data[i][j] += self.data[i][j - 1] + self.data[i - 1][j] - self.data[i - 1][j - 1]

proc query[T](self: CumulativeSum2D[T], sx, sy, gx, gy:int):T =
  return self.data[gx][gy] - self.data[sx][gy] - self.data[gx][sy] + self.data[sx][sy]
