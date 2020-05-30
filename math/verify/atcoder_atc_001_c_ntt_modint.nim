{.hints:off checks:off}
import algorithm, sequtils, tables, macros, math, sets, strutils, streams, sugar
when defined(MYDEBUG):
  import header

proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc getchar(): char {.header: "<stdio.h>", varargs.}
proc nextInt(base:int = 0): int =
  scanf("%lld",addr result)
  result -= base
proc nextFloat(): float = scanf("%lf",addr result)
proc nextString(): string =
  var get = false;result = ""
  while true:
    var c = getchar()
    if int(c) > int(' '): get = true;result.add(c)
    elif get: break
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

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



const MOD = 1012924417

#{{{ ModInt[Mod]
proc getDefault(T:typedesc): T = (var temp:T;temp)
proc getDefault[T](x:T): T = (var temp:T;temp)

type ModInt[Mod: static[int]] = object
  v:int
proc initModInt[T](a:T, Mod: static[int]):ModInt[Mod] =
  when T is ModInt[Mod]:
    return a
  else:
    var a = a
    a = a mod Mod
    if a < 0: a += Mod
    result.v = a
proc init[T](self:ModInt[Mod], a:T):ModInt[Mod] = initModInt(a, Mod)
proc Identity(self:ModInt[Mod]):ModInt[Mod] = return initModInt(1, Mod)

proc `==`[T](a:ModInt[Mod], b:T):bool = a.v == initModInt(b, Mod).v
proc `!=`[T](a:ModInt[Mod], b:T):bool = a.v != initModInt(b, Mod).v
proc `-`(self:ModInt[Mod]):ModInt[Mod] =
  if self.v == 0: return self
  else: return ModInt[Mod](v:MOD - self.v)
proc `$`(a:ModInt[Mod]):string = return $(a.v)

proc `+=`[T](self:var ModInt[Mod]; a:T):void =
  self.v += initModInt(a, Mod).v
  if self.v >= MOD: self.v -= MOD
proc `-=`[T](self:var ModInt[Mod],a:T):void =
  self.v -= initModInt(a, Mod).v
  if self.v < 0: self.v += MOD
proc `*=`[T](self:var ModInt[Mod],a:T):void =
  self.v *= initModInt(a, Mod).v
  self.v = self.v mod MOD
proc `^=`(self:var ModInt[Mod], n:int) =
  var (x,n,a) = (self,n,self.Identity)
  while n > 0:
    if (n and 1) > 0: a *= x
    x *= x
    n = (n shr 1)
  swap(self, a)
proc inverse(x:int):ModInt[Mod] =
  var (a, b) = (x, MOD)
  var (u, v) = (1, 0)
  while b > 0:
    let t = a div b
    a -= t * b;swap(a,b)
    u -= t * v;swap(u,v)
  return initModInt(u, Mod)
proc `/=`[T](a:var ModInt[Mod],b:T):void = a *= initModInt(b, Mod).v.inverse()
proc `+`[T](a:ModInt[Mod],b:T):ModInt[Mod] = result = a;result += b
proc `-`[T](a:ModInt[Mod],b:T):ModInt[Mod] = result = a;result -= b
proc `*`[T](a:ModInt[Mod],b:T):ModInt[Mod] = result = a;result *= b
proc `/`[T](a:ModInt[Mod],b:T):ModInt[Mod] = result = a; result /= b
proc `^`(a:ModInt[Mod],b:int):ModInt[Mod] = result = a; result ^= b
#}}}

type Mint = ModInt[Mod]
proc initMint[T](a:T):ModInt[Mod] = initModInt(a, Mod)




# NumberTheoricTransform using Modint {{{
proc builtin_popcount(n: int): int{.importc: "__builtin_popcount", nodecl.}
proc builtin_ctz(n: int): int{.importc: "__builtin_ctz", nodecl.}
proc llround(n: float): int{.importc: "llround", nodecl.}

type NumberTheoreticTransform = object
  rev: seq[int]
  rts: seq[ModInt[Mod]]
  base, max_base:int
  root: ModInt[Mod]

proc initNumberTheoreticTransform():NumberTheoreticTransform =
  result = NumberTheoreticTransform(base:1, rev: @[0, 1], rts: @[initMint(0), initMint(1)])
  assert(Mod >= 3 and Mod mod 2 == 1)
  var tmp = Mod - 1
  var max_base = 0
  while tmp mod 2 == 0: tmp = tmp shr 1; max_base+=1
  var root = initMint(2)
  while root^((Mod - 1) shr 1) == 1: root += 1
  assert(root^(Mod - 1) == 1)
  root = root^((Mod - 1) shr max_base)
  result.max_base = max_base
  result.root = root

proc ensure_base(self: var NumberTheoreticTransform;nbase:int) =
  if nbase <= self.base: return
  self.rev.setLen(1 shl nbase)
  self.rts.setLen(1 shl nbase)
  for i in 0..<(1 shl nbase):
    self.rev[i] = (self.rev[i shr 1] shr 1) + ((i and 1) shl (nbase - 1))
  assert(nbase <= self.max_base)
  while self.base < nbase:
    let z = self.root^(1 shl (self.max_base - 1 - self.base))
    for i in 1 shl (self.base - 1) ..< 1 shl self.base:
      self.rts[i shl 1] = self.rts[i]
      self.rts[(i shl 1) + 1] = self.rts[i] * z
    self.base += 1

proc ntt(self: var NumberTheoreticTransform;a:var seq[ModInt[Mod]]) =
  let n = a.len
  assert((n and (n - 1)) == 0)
  let zeros = builtin_ctz(n)
  self.ensureBase(zeros)
  let shift = self.base - zeros
  for i in 0..<n:
    if i < (self.rev[i] shr shift):
      swap(a[i], a[self.rev[i] shr shift])
  var k = 1
  while k < n:
    var i = 0
    while i < n:
      for j in 0..<k:
        let z = a[i + j + k] * self.rts[j + k]
        a[i + j + k] = a[i + j] - z
        a[i + j] = a[i + j] + z
      i += 2 * k
    k = k shl 1

proc intt(self: var NumberTheoreticTransform;a:var seq[ModInt[Mod]]) =
  let n = a.len
  self.ntt(a)
  a.reverse(1, a.len - 1)
  let inv_sz = initMint(1) / n
  for i in 0..<n: a[i] *= inv_sz

proc multiply(self: var NumberTheoreticTransform;a,b: var seq[ModInt[Mod]]):seq[ModInt[Mod]] =
  let need = a.len + b.len - 1
  var nbase = 1
  while (1 shl nbase) < need: nbase += 1
  self.ensureBase(nbase)
  let sz = 1 shl nbase
  a.setLen(sz)
  b.setLen(sz)
  self.ntt(a)
  self.ntt(b)
  let inv_sz = initMint(1) / sz
  for i in 0..<sz: a[i] *= b[i] * inv_sz
  a.reverse(1, a.len - 1)
  self.ntt(a)
  a.setLen(need)
  return a
#}}}

block main:
  let N = nextInt()
  var A, B = newSeq[Mint](N+1)
  for i in 0..<N:
    A[i+1] = initMint(nextInt())
    B[i+1] = initMint(nextInt())
  var ntt = initNumberTheoreticTransform()
  let C = ntt.multiply(A, B)
  for i in 1..2*N: echo C[i]

