{.hints:off checks:off}
import algorithm, sequtils, tables, macros, math, sets, strutils, streams
when defined(MYDEBUG):
  import header

when (not (NimMajor <= 0)) or NimMinor >= 19:
  import sugar
else:
  import future
  proc sort[T](a:var seq[T]) = a.sort(cmp[T])

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

proc builtin_popcount(n: int): int{.importc: "__builtin_popcount", nodecl.}
proc builtin_ctz(n: int): int{.importc: "__builtin_ctz", nodecl.}
proc llround(n: float): int{.importc: "llround", nodecl.}

import math, sequtils

type Real = float

type C = object
  x, y:Real

proc initC():C = C(x:0.0, y:0.0)
proc initC[S,T](x:S, y:T):C = C(x:x.float, y:y.float)

proc `+`(a,b:C):C = initC(a.x + b.x, a.y + b.y)
proc `-`(a,b:C):C = initC(a.x - b.x, a.y - b.y)
proc `*`(a,b:C):C = initC(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x)
proc conj(a:C):C = initC(a.x, -a.y)

type FastFourierTransform = object
  base:int
  rts:seq[C]
  rev:seq[int]

proc initFastFourierTransform():FastFourierTransform = 
  return FastFourierTransform(base:1, rts: @[initC(0,0),initC(1,0)], rev: @[0, 1])

proc ensureBase(self:var FastFourierTransform;nbase:int) =
  if nbase <= self.base: return
  self.rev.setlen(1 shl nbase)
  self.rts.setlen(1 shl nbase)
  for i in 0..<(1 shl nbase): self.rev[i] = (self.rev[i shr 1] shr 1) + ((i and 1) shl (nbase - 1))
  while self.base < nbase:
    let angle = PI * 2.0 / float(1 shl (self.base + 1))
    for i in (1 shl (self.base - 1))..<(1 shl self.base):
      self.rts[i shl 1] = self.rts[i]
      let angle_i = angle * float(2 * i + 1 - (1 shl self.base))
      self.rts[(i shl 1) + 1] = initC(cos(angle_i), sin(angle_i))
    self.base.inc

proc fft(self:var FastFourierTransform; a:var seq[C], n:int) =
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

proc multiply(self:var FastFourierTransform; a,b:seq[int]):seq[int] =
  let need = a.len + b.len - 1
  var nbase = 1
  while (1 shl nbase) < need: nbase.inc
  self.ensureBase(nbase)
  let sz = 1 shl nbase
  var fa = newSeqWith(sz, initC())
  for i in 0..<sz:
    let x = if i < a.len: a[i] else: 0
    let y = if i < b.len: b[i] else: 0
    fa[i] = initC(x, y)
  self.fft(fa, sz)
  let
    r = initC(0, -0.25 / float(sz shr 1))
    s = initC(0, 1)
    t = initC(0.5, 0)
  for i in 0..(sz shr 1):
    let j = (sz - i) and (sz - 1)
    let z = (fa[j] * fa[j] - (fa[i] * fa[i]).conj()) * r
    fa[j] = (fa[i] * fa[i] - (fa[j] * fa[j]).conj()) * r
    fa[i] = z
  for i in 0..<(sz shr 1):
    let A0 = (fa[i] + fa[i + (sz shr 1)]) * t
    let A1 = (fa[i] - fa[i + (sz shr 1)]) * t * self.rts[(sz shr 1) + i]
    fa[i] = A0 + A1 * s
  self.fft(fa, sz shr 1)
  var ret = newSeq[int](need)
  for i in 0..<need: ret[i] = llround(if (i and 1)>0: fa[i shr 1].y else: fa[i shr 1].x)
  return ret

block main:
  N := nextInt()
  A := newSeq[int](N+1)
  B := newSeq[int](N+1)
  for i in 1..N:
    A[i] = nextInt()
    B[i] = nextInt()
  var fft = initFastFourierTransform()
  let C = fft.multiply(A, B);
  for i in 1..2*N: echo C[i]
