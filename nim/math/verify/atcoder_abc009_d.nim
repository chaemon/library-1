#{{{ header
{.hints:off checks:off.}
import algorithm, sequtils, tables, macros, math, sets, strutils, future
when defined(MYDEBUG):
  import header

proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc getchar(): char {.header: "<stdio.h>", varargs.}
proc nextInt(): int = scanf("%lld",addr result)
proc nextFloat(): float = scanf("%lf",addr result)
proc nextString(): string =
  var get = false
  result = ""
  while true:
    var c = getchar()
    if int(c) > int(' '):
      get = true
      result.add(c)
    else:
      if get: break
      get = false
type someInteger = int|int8|int16|int32|int64|BiggestInt
type someUnsignedInt = uint|uint8|uint16|uint32|uint64
type someFloat = float|float32|float64|BiggestFloat
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)
template inf(T): untyped = 
  when T is someFloat: T(Inf)
  elif T is someInteger|someUnsignedInt: ((T(1) shl T(sizeof(T)*8-2)) - (T(1) shl T(sizeof(T)*4-1)))
  else: assert(false)

proc sort[T](v: var seq[T]) = v.sort(cmp[T])

proc discardableId[T](x: T): T {.discardable.} =
  return x
macro `:=`(x, y: untyped): untyped =
  if (x.kind == nnkIdent):
    return quote do:
      when declaredInScope(`x`):
        `x` = `y`
      else:
        var `x` = `y`
      discardableId(`x`)
  else:
    return quote do:
      `x` = `y`
      discardableId(`x`)
#}}}

#{{{ bitset
import strutils, sequtils, algorithm

let BitWidth = 64

#{{{ bitutils
proc bits(v:varargs[int]): uint64 =
  result = 0
  for x in v: result = (result or (1'u64 shl uint64(x)))
proc `[]`(b:uint64,n:int):int =
  if (b and (1'u64 shl uint64(n))) == 0: 0 else: 1
proc test(b:uint64,n:int):bool =
  if b[n] == 1:true else: false
proc set(b:var uint64,n:int) = b = (b or (1'u64 shl uint64(n)))
proc unset(b:var uint64,n:int) = b = (b and (not (1'u64 shl uint64(n))))
proc `[]=`(b:var uint64,n:int,t:int) =
  if t == 0: b.unset(n)
  elif t == 1: b.set(n)
  else: assert(false)
proc writeBits(b:uint64,n:int = 64) =
  for i in countdown(n-1,0):stdout.write(b[i])
  echo ""
proc setBits(n:int):uint64 =
  if n == 64: (not 0'u64)
  else: (1'u64 shl uint64(n)) - 1'u64
#}}}

proc toBin(b:uint64, n: int): string =
  result = ""
  for i in countdown(n-1, 0):
    if (b and (1'u64 shl uint64(i))) != 0'u64: result &= "1"
    else: result &= "0"

type BitSet = object
  len: int
  data: seq[uint64]

proc initBitSet(n: int): BitSet =
  var q = n div BitWidth
  if n mod BitWidth != 0: q += 1
  return BitSet(len:n, data: newSeq[uint64](q))
proc initBitSet1(n: int): BitSet =
  var
    q = n div BitWidth
    r = n mod BitWidth
  result = BitSet(len:n, data: newSeq[uint64]())
  for i in 0..<q:result.data.add(not 0'u64)
  if r > 0:result.data.add((1'u64 shl uint64(r)) - 1)
proc init(self: BitSet, n: int): BitSet = initBitSet(n)

proc `not`(a: BitSet): BitSet =
  result = initBitSet1(a.len)
  for i in 0..<a.data.len: result.data[i] = (not a.data[i]) and result.data[i]
proc `or`(a, b: BitSet): BitSet =
  assert(a.len == b.len)
  result = initBitSet(a.len)
  for i in 0..<a.data.len: result.data[i] = a.data[i] or b.data[i]
proc `and`(a, b: BitSet): BitSet =
  assert(a.len == b.len)
  result = initBitSet(a.len)
  for i in 0..<a.data.len: result.data[i] = a.data[i] and b.data[i]
proc `xor`(a, b: BitSet): BitSet =
  assert(a.len == b.len)
  result = initBitSet(a.len)
  for i in 0..<a.data.len: result.data[i] = a.data[i] xor b.data[i]

proc `$`(a: BitSet):string =
  var
    q = a.len div BitWidth
    r = a.len mod BitWidth
  var v = newSeq[string]()
  for i in 0..<q:
    v.add(a.data[i].toBin(BitWidth))
  if r > 0:
    v.add(a.data[q].toBin(r))
  v.reverse()
  return v.join("")

proc `[]`(b:BitSet,n:int):int =
  assert 0 <= n and n < b.len
  let
    q = n div BitWidth
    r = n mod BitWidth
  return b.data[q][r]
proc `[]=`(b:var BitSet,n:int,t:int) =
  assert 0 <= n and n < b.len
  assert t == 0 or t == 1
  let
    q = n div BitWidth
    r = n mod BitWidth
  b.data[q][r] = t

proc `shl`(a: BitSet, n:int): BitSet =
  result = initBitSet(a.len)
  var r = n mod BitWidth
  if r < 0: r += BitWidth
  let q = (n - r) div BitWidth
  let maskl = setBits(BitWidth - r)
  for i in 0..<a.data.len:
    let d = (a.data[i] and maskl) shl uint64(r)
    let i2 = i + q
    if 0 <= i2 and i2 < a.data.len: result.data[i2] = result.data[i2] or d
  if r != 0:
    let maskr = setBits(r) shl uint64(BitWidth - r)
    for i in 0..<a.data.len:
      let d = (a.data[i] and maskr) shr uint64(BitWidth - r)
      let i2 = i + q + 1
      if 0 <= i2 and i2 < a.data.len: result.data[i2] = result.data[i2] or d
  block:
    let r = a.len mod BitWidth
    if r != 0:
      let mask = not (setBits(BitWidth - r) shl uint64(r))
      result.data[^1] = result.data[^1] and mask
proc `shr`(a: BitSet, n:int): BitSet = a shl (-n)
#}}}

#{{{ bitMatrix
proc getDefault(V:typedesc): V = (var temp:V;temp)
proc getDefault[V](x:V): V = (var temp:V;temp)

import sequtils

type Matrix[V] = seq[V]

proc initMatrix[V](self: Matrix[V]):Matrix[V] = return self
proc initMatrix[V](n:int, m: int):Matrix[V] = Matrix[V](newSeqWith(n, getDefault(V).init(m)))
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
#}}}

proc solve(K:int, M:int, A:seq[int], C:seq[int]) =
  var ans = 0
  for i in 0..<32:
    var AA = initMatrix[BitSet](K)
    var b = initBitSet(K)
    for j in 0..<K:
      if (A[j] and (1 shl i)) > 0: b[j] = 1
    for j in 0..<K-1:AA[j][j+1] = 1
    for j in 0..<K:
      if (C[K - 1 - j] and (1 shl i)) > 0: AA[K-1][j] = 1
    AA ^= (M - 1)
    if (AA*b)[0] == 1:
      ans = ans or (1 shl i)
  echo ans
  return

#{{{ main function
proc main() =
  var K = 0
  K = nextInt()
  var M = 0
  M = nextInt()
  var A = newSeqWith(K, 0)
  for i in 0..<K:
    A[i] = nextInt()
  var C = newSeqWith(K, 0)
  for i in 0..<K:
    C[i] = nextInt()
  solve(K, M, A, C);
  return

main()
#}}}
