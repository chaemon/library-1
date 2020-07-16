# number_theoretic_transform {{{
import sequtils, algorithm, bitops

type NumberTheoreticTransform[ModInt] = object
  rev: seq[int]
  rts: seq[ModInt]
  base, max_base:int
  root: ModInt

proc initNumberTheoreticTransform[ModInt](root0 = -1):NumberTheoreticTransform[ModInt] =
  let Mod = ModInt.getMod()
  result = NumberTheoreticTransform[ModInt](base:1, rev: @[0, 1], rts: @[ModInt(0), ModInt(1)])
  assert(Mod >= 3 and Mod mod 2 == 1)
  var tmp = Mod - 1
  var max_base = 0
  while tmp mod 2 == 0: tmp = tmp shr 1; max_base+=1
  var root:ModInt
  if root0 == -1:
    root = ModInt(2)
    while root^((Mod - 1) shr 1) == 1: root += 1
  else:
    root = ModInt(root0)
  assert(root^(Mod - 1) == 1)
  root = root^((Mod - 1) shr max_base)
  result.max_base = max_base
  result.root = root

proc init[ModInt](self: typedesc[NumberTheoreticTransform[ModInt]]):auto = initNumberTheoreticTransform[ModInt]()

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

proc fft[ModInt](self: var NumberTheoreticTransform[ModInt];a:seq[ModInt]):auto =
  var a = a
  let n = a.len
  assert((n and (n - 1)) == 0)
  let zeros = countTrailingZeroBits(n)
  self.ensureBase(zeros)
  let shift = self.base - zeros
  for i in 0..<n:
    let j = self.rev[i] shr shift
    if i < j:
      swap(a[i], a[j])
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
  return a

proc ifft[ModInt](self: var NumberTheoreticTransform[ModInt];a:seq[ModInt]):auto =
  var a = a
  let n = a.len
  a = self.fft(a)
  a.reverse(1, a.len - 1)
  let inv_sz = ModInt(1) / ModInt(n)
  for i in 0..<n: a[i] *= inv_sz
  return a
proc dot[ModInt](self: NumberTheoreticTransform[ModInt], a,b: seq[ModInt]):seq[ModInt] =
  result = newSeq[ModInt](a.len)
  for i in 0..<a.len: result[i] = a[i] * b[i]

proc multiply[ModInt](self: var NumberTheoreticTransform[ModInt];a,b: seq[ModInt]):seq[ModInt] =
  var (a,b) = (a,b)
  let need = a.len + b.len - 1
  var nbase = 1
  while (1 shl nbase) < need: nbase += 1
  self.ensureBase(nbase)
  let sz = 1 shl nbase
  while a.len < sz: a.add(ModInt(0))
  while b.len < sz: b.add(ModInt(0))
  a.setLen(sz)
  b.setLen(sz)
  a = self.ifft(self.dot(self.fft(a), self.fft(b)))
  while a.len < need: a.add(ModInt(0))
  a.setLen(need)
  return a
#}}}
