# Matrix {{{
import sequtils

type Matrix[T] = seq[seq[T]]
type Vector[T] = seq[T]

proc height[T](self: Matrix[T]):int = self.len
proc width[T](self: Matrix[T]):int = self[0].len

proc initMatrix[T](self: Matrix[T]):Matrix[T] = return self
proc initMatrix[T](n, m:int):Matrix[T] = Matrix[T](newSeqWith(n, newSeqWith(m, T.default)))
proc initMatrix[T](n:int):Matrix[T] = Matrix[T](newSeqWith(n, newSeqWith(n, T.default)))

proc initMatrix[T](a:seq[seq[int]]):Matrix[T] =
  result = initMatrix[T](a.len, a[0].len)
  for i in 0..<result.height:
    for j in 0..<result.width:
      result[i][j] = T(a[i][j])

proc initVector[T](n:int):Vector[T] = Vector[T](newSeqWith(n, T.default))
proc initVector[T](a:seq[int]):Vector[T] =
  result = initVector[T](a.len)
  for i in 0..<result.len: result[i] = T(a[i])

proc Identity[T](n:int):Matrix[T] =
  result = initMatrix[T](n)
  for i in 0..<n: result[i][i] = T(1)
proc Identity[T](self: Matrix[T]):Matrix[T] = Identity[T](self.height)

import sugar

proc getIsZeroImpl[T](self:Matrix[T], update = false, f:(T)->bool = nil):(T)->bool {.discardable.} =
  var isZero{.global.}:(a:T)->bool  = (a:T) => a == T(0)
  if update:isZero = f
  return isZero
proc getIsZero[T](self:Matrix[T]):(T)->bool = self.getIsZeroImpl()
proc setIsZero[T](self:Matrix[T], isZero:proc(a:T):bool) = self.getIsZeroImpl(true, isZero)

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
  var B = self
  assert(self.width() == self.height())
  result = T(1)
  for i in 0..<self.width():
    var idx = -1
    for j in i..<self.width():
      if not (self.getIsZero())(B[j][i]):
        idx = j;break
    if idx == -1: return T(0)
    if i != idx:
      result *= T(-1)
      swap(B[i], B[idx])
    result *= B[i][i]
    let vv = B[i][i]
    for j in 0..<self.width():
      B[i][j] /= vv
    for j in i+1..<self.width():
      let a = B[j][i]
      for k in 0..<self.width():
        B[j][k] -= B[i][k] * a
# }}}
