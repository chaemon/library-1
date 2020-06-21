import sequtils

type Matrix[V] = seq[V]

proc initMatrix[V](self: Matrix[V]):Matrix[V] = return self
proc initMatrix[V](n:int, m: int):Matrix[V] = Matrix[V](newSeqWith(n, V.default.init(m)))
proc initMatrix[V](n:int):Matrix[V] = initMatrix[V](n, n)

#proc initVector[V](n:int):Vector[V] = Vector[V](newSeqWith(n, getDefault(V)))

proc height[V](self: Matrix[V]):int = self.len
proc width[V](self: Matrix[V]):int = self[0].len

proc I[V](n:int):Matrix[V] =
  result = initMatrix[V](n)
  for i in 0..<n: result[i][i] = 1

proc `+=`[V](self: var Matrix[V], B: Matrix[V]) =
  let (n, m) = (self.height, self.width)
  assert(n == B.height() and m == B.width())
  for i in 0..<n:
    self[i] = self[i] xor B[i]

proc `*=`[V](self: var Matrix[V], B: Matrix[V]) =
  let (n,m,p) = (self.height, B.width, self.width)
  assert(p == B.height())
  var C = initMatrix[V](n, m)
  for i in 0..<n:
    for k in 0..<p:
      if self[i][k] == 1: C[i] = C[i] xor B[k]
  swap(self, C)
proc `*`[V](self: Matrix[V], v: V): seq[int] =
  let (n,m) = (self.height, self.width)
  result = newSeq[int](n)
  assert(v.len == m)
  for i in 0..<n:
    for j in 0..<m:
      if self[i][j] == 1:
#        result[i] += self[i][j] * v[j]
        result[i] += v[j]
        result[i] = result[i] mod 2

proc `^=`[V](self: var Matrix[V], k:int) =
  var k = k
  var B = I[V](self.height())
  while k > 0:
    if (k and 1)>0:
      B *= self
    self *= self;k = k shr 1
  self.swap(B)

proc `+`[V](self: Matrix[V], B:Matrix[V]):Matrix[V] =
  result = initMatrix(self); result += B
proc `*`[V](self: Matrix[V], B:Matrix[V]):Matrix[V] =
  result = initMatrix(self); result *= B
proc `^`[V](self: Matrix[V], k:int):Matrix[V] =
  result = initMatrix(self); result ^= k

proc `$`[V](self: Matrix[V]):string =
  result = ""
  let (n,m) = (self.height, self.width)
  for i in 0..<n:
    result &= "["
    result &= $(self[i])
    result &= "]\n"
