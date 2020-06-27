import sequtils, algorithm

include "../standard_library/bitutils.nim"

type NumberTheoreticTransform[ModInt] = object
  rev: seq[int]
  rts: seq[ModInt]
  base, max_base:int
  root: ModInt

proc initNumberTheoreticTransform[ModInt]():NumberTheoreticTransform[ModInt] =
  let Mod = ModInt.Mod
  result = NumberTheoreticTransform[ModInt](base:1, rev: @[0, 1], rts: @[ModInt(0), ModInt(1)])
  assert(Mod >= 3 and Mod mod 2 == 1)
  var tmp = Mod - 1
  var max_base = 0
  while tmp mod 2 == 0: tmp = tmp shr 1; max_base+=1
  var root = ModInt(2)
  while root^((Mod - 1) shr 1) == 1: root += 1
  assert(root^(Mod - 1) == 1)
  root = root^((Mod - 1) shr max_base)
  result.max_base = max_base
  result.root = root

proc ensureBase[ModInt](self: var NumberTheoreticTransform[ModInt];nbase:int) =
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

proc fft[ModInt](self: var NumberTheoreticTransform[ModInt];a:var seq[ModInt]) =
  let n = a.len
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

proc ifft[ModInt](self: var NumberTheoreticTransform[ModInt];a:var seq[ModInt]) =
  let n = a.len
  self.fft(a)
  a.reverse(1, a.len - 1)
  let inv_sz = ModInt(1) / n
  for i in 0..<n: a[i] *= inv_sz

proc multiply[ModInt](self: var NumberTheoreticTransform[ModInt];a,b: seq[ModInt]):seq[ModInt] =
  var (a,b) = (a,b)
  let need = a.len + b.len - 1
  var nbase = 1
  while (1 shl nbase) < need: nbase += 1
  self.ensureBase(nbase)
  let sz = 1 shl nbase
  a.setLen(sz)
  b.setLen(sz)
  self.fft(a)
  self.fft(b)
  let inv_sz = ModInt(1) / sz
  for i in 0..<sz: a[i] *= b[i] * inv_sz
  a.reverse(1, a.len - 1)
  self.fft(a)
  a.setLen(need)
  return a
#}}}
