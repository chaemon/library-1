# Matrix {{{
import sequtils

type Matrix[T] = seq[seq[T]]
type Vector[T] = seq[T]

proc height[T](self: Matrix[T]):int = self.len
proc width[T](self: Matrix[T]):int = self[0].len

#template initMatrix[T](self: Matrix[T]):Matrix[T] = return self
template initMatrix[T](n, m:int):Matrix[T] = newSeqWith(n, newSeqWith(m, T.default))
template initMatrix[T](self: Matrix[T], n, m:int):Matrix[T] = newSeqWith(n, newSeqWith(m, T.default))
template initMatrix[T](n:int):Matrix[T] = newSeqWith(n, newSeqWith(n, T.default))

type RingElem = concept x, type T
  x + x
  x - x
  x * x
  T(1)
  T(0)
type FieldElem = concept x, type T
  x is RingElem
  x / x

type XC = concept x
  true
type DoubleSeqC = concept x
  x[0][0] is SomeNumber

template initMatrix[T](a:DoubleSeqC):Matrix[T] =
  when a is seq[seq[T]]:
    a
  else:
    var A = initMatrix[T](a.len, a[0].len)
    for i in 0..<A.height:
      for j in 0..<A.width:
        A[i][j] = T(a[i][j])
    A

template initVector[T](n:int):Vector[T] = Vector[T](newSeqWith(n, T.default))
template initVector[T](a:openArray[XC]):Vector[T] =
  when a is seq[T]:
    a
  else:
    var v = initVector[T](a.len)
    for i in 0..<v.len: v[i] = T(a[i])
    v

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

proc `+=`(self: var Matrix[RingElem], B: Matrix[RingElem]) =
  let (n, m) = (self.height, self.width)
  assert(n == B.height() and m == B.width())
  for i in 0..<n:
    for j in 0..<m:
      self[i][j] += B[i][j]

proc `-=`(self: var Matrix[RingElem], B: Matrix[RingElem]) =
  let (n, m) = (self.height, self.width)
  assert(n == B.height() and m == B.width())
  for i in 0..<n:
    for j in 0..<m:
      self[i][j] -= B[i][j]

proc `*=`[T:RingElem](self: var Matrix[T], B: Matrix[T]) =
  let (n,m,p) = (self.height, B.width, self.width)
  assert(p == B.height)
  var C = initMatrix[T](n, m)
  for i in 0..<n:
    for j in 0..<m:
      for k in 0..<p:
        C[i][j] += self[i][k] * B[k][j]
  swap(self, C)
proc `*`[T:RingElem](self: Matrix[T], v: Vector[T]): Vector[T] =
  let (n,m) = (self.height, self.width)
  result = initVector[T](n)
  assert(v.len == m)
  for i in 0..<n:
    for j in 0..<m:
        result[i] += self[i][j] * v[j]

proc `+`(self: Matrix[RingElem], B:Matrix[RingElem]):auto =
  result = self; result += B
proc `-`(self: Matrix[RingElem], B:Matrix[RingElem]):auto =
  result = self; result -= B
proc `*`[T:RingElem](self: Matrix[T], B:Matrix[T]):Matrix[T] =
  result = self; result *= B

proc `$`(self: Matrix[RingElem]):string =
  result = ""
  let (n,m) = (self.height, self.width)
  for i in 0..<n:
    result &= "["
    for j in 0..<m:
      result &= $(self[i][j])
      result &= (if j + 1 == m: "]\n" else: ",")

proc determinant[T:FieldElem](self: Matrix[T]):auto =
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
