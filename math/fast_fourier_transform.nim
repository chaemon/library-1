#{{{ FastFourierTransform
include "standard_library/bitutils.nim"

proc llround(n: float): int{.importc: "llround", nodecl.}

# LongDouble {{{
type LongDouble {.importcpp: "long double", nodecl .} = object
  discard

proc initLongDouble(a:SomeNumber):LongDouble {.importcpp: "(long double)(#)", nodecl.}
converter toLongDouble(a:SomeNumber):LongDouble = initLongDouble(a)

proc `+`(a, b:LongDouble):LongDouble {.importcpp: "(#) + (@)", nodecl.}
proc `-`(a, b:LongDouble):LongDouble {.importcpp: "(#) - (@)", nodecl.}
proc `*`(a, b:LongDouble):LongDouble {.importcpp: "(#) * (@)", nodecl.}
proc `/`(a, b:LongDouble):LongDouble {.importcpp: "(#) / (@)", nodecl.}
proc `-`(a:LongDouble):LongDouble {.importcpp: "-(#)", nodecl.}
proc `sqrt`(a:LongDouble):LongDouble {.header: "<cmath>", importcpp: "sqrtl(#)", nodecl.}
proc `exp`(a:LongDouble):LongDouble {.header: "<cmath>", importcpp: "expl(#)", nodecl.}
proc `sin`(a:LongDouble):LongDouble {.header: "<cmath>", importcpp: "sinl(#)", nodecl.}
proc `cos`(a:LongDouble):LongDouble {.header: "<cmath>", importcpp: "cosl(#)", nodecl.}
proc `llround`(a:LongDouble):int {.header: "<cmath>", importcpp: "llround(#)", nodecl.}
# }}}


import math, sequtils, bitops

type Real = float
#type Real = LongDouble

type C = object
  x, y:Real

proc initC():C = C(x:0.Real, y:0.Real)
proc initC[S,T](x:S, y:T):C = C(x:x.Real, y:y.Real)

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

proc ensureBase(self:var FastFourierTransform; nbase:int) =
  block test:
    var v = newSeq[C]()
    v.add(initC())
  if nbase <= self.base: return
  let L = 1 shl nbase
  self.rev.setlen(1 shl nbase)
  self.rts.setlen(1 shl nbase)
#  while self.rts.len < L:
#    dump(self.rts.len)
#    dump(initC(0, 0))
#    self.rts.add(initC(0, 0))
#    echo self.rts
  for i in 0..<(1 shl nbase): self.rev[i] = (self.rev[i shr 1] shr 1) + ((i and 1) shl (nbase - 1))
  while self.base < nbase:
    let angle = Real(PI) * Real(2) / Real(1 shl (self.base + 1))
    for i in (1 shl (self.base - 1))..<(1 shl self.base):
      self.rts[i shl 1] = self.rts[i]
      let angle_i = angle * Real(2 * i + 1 - (1 shl self.base))
      self.rts[(i shl 1) + 1] = initC(cos(angle_i), sin(angle_i))
    self.base.inc

proc fft(self:var FastFourierTransform; a:var seq[C], n:int) =
  assert((n and (n - 1)) == 0)
  let zeros = countTrailingZeroBits(n)
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
#    r = initC(0, -0.25 / float(sz shr 1))
    r = initC(0, -Real(1) / (Real(sz shr 1) * Real(4)))
    s = initC(0, 1)
#    t = initC(0.5, 0)
    t = initC(Real(1)/Real(2), 0)
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
#}}}
