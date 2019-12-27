proc getDefault(T:typedesc): T = (var temp:T;temp)
proc getDefault[T](x:T): T = (var temp:T;temp)

import sequtils

type Matrix[T] = seq[seq[T]]
type Vector[T] = seq[T]

proc initMatrix[T](self: Matrix[T]):Matrix[T] = return self
proc initMatrix[T](n:int, m: int):Matrix[T] = Matrix[T](newSeqWith(n, newSeqWith(m, getDefault(T))))
proc initMatrix[T](n:int):Matrix[T] = Matrix[T](newSeqWith(n, newSeqWith(n, getDefault(T))))

proc initVector[T](n:int):Vector[T] = Vector[T](newSeqWith(n, getDefault(T)))

proc height[T](self: Matrix[T]):int = self.len
proc width[T](self: Matrix[T]):int = self[0].len

proc Identity[T](n:int):Matrix[T] =
  result = initMatrix[T](n)
  for i in 0..<n: result[i][i] = getDefault(T).init(1)
proc Identity[T](self: Matrix[T]):Matrix[T] =
  result = initMatrix[T](self.n)
  for i in 0..<self.n: result[i][i] = getDefault(T).init(1)

proc `+=`[T](self: var Matrix[T], B: Matrix[T]) =
  let (n, m) = (self.height, self.width)
  assert(n == B.height() and m == B.width())
  for i in 0..<n:
    for j in 0..<m:
      self[i][j] += B[i][j]

proc `-=`[T](self: var Matrix[T], B: Matrix[T]) =
  let (n, m) = (self.height, self.width)
  assert(n == B.height() and m == B.width())
  for i in 0..<n:
    for j in 0..<m:
      self[i][j] -= B[i][j]

proc `*=`[T](self: var Matrix[T], B: Matrix[T]) =
  let (n,m,p) = (self.height, B.width, self.width)
  assert(p == B.height())
  var C = initMatrix[T](n, m)
  for i in 0..<n:
    for j in 0..<m:
      for k in 0..<p:
        C[i][j] += self[i][k] * B[k][j]
  swap(self, C)
proc `*`[T](self: Matrix[T], v: Vector[T]): Vector[T] =
  let (n,m) = (self.height, self.width)
  result = initVector[T](n)
  assert(v.len == m)
  var C = initMatrix[T](n, m)
  for i in 0..<n:
    for j in 0..<m:
        result[i] += self[i][j] * v[j]

proc `+`[T](self: Matrix[T], B:Matrix[T]):Matrix[T] =
  result = self; result += B
proc `-`[T](self: Matrix[T], B:Matrix[T]):Matrix[T] =
  result = self; result -= B
proc `*`[T](self: Matrix[T], B:Matrix[T]):Matrix[T] =
  result = self; result *= B

proc `$`[T](self: Matrix[T]):string =
  result = ""
  let (n,m) = (self.height, self.width)
  for i in 0..<n:
    result &= "["
    for j in 0..<m:
      result &= $(self[i][j])
      result &= (if j + 1 == m: "]\n" else: ",")

proc determinant[T](self: Matrix[T]):T =
  var B = initMatrix(self)
  assert(self.width() == self.height());
  result = getDefault(T).init(1)
  for i in 0..<self.width():
    var idx = -1
    for j in i..<self.width():
      if B[j][i] != getDefault(T).init(0): idx = j
    if idx == -1: return getDefault(T).init(0)
    if i != idx:
      result *= getDefault(T).init(-1)
      swap(B[i], B[idx])
    result *= B[i][i];
    let vv = B[i][i]
    for j in 0..<self.width():
      B[i][j] /= vv
    for j in i+1..<self.width():
      let a = B[j][i]
      for k in 0..<self.width():
        B[j][k] -= B[i][k] * a;

