#{{{ NumberTheoricTransform
import algorithm

when not declared(Mod):
  const Mod = 1012924417

include "../standard_library/bitutils.nim"
#proc builtin_popcount(n: int): int{.importc: "__builtin_popcount", nodecl.}
#proc builtin_ctz(n: int): int{.importc: "__builtin_ctz", nodecl.}
proc llround(n: float): int{.importc: "llround", nodecl.}

type NumberTheoreticTransform = object
  rev, rts: seq[int]
  base, max_base, root:int

proc add(self: NumberTheoreticTransform;x,y:int):int =
  result = x + y
  if result >= Mod: result -= Mod

proc mul(self: NumberTheoreticTransform;a,b:int):int =
  return a * b mod Mod

proc modPow(self:NumberTheoreticTransform;x, n:int):int =
  var (x,n) = (x,n)
  result = 1
  while n > 0:
    if (n and 1) > 0: result = self.mul(result, x)
    x = self.mul(x, x)
    n = n shr 1

proc inverse(self:NumberTheoreticTransform;x:int):int = self.modPow(x, Mod - 2)

proc initNumberTheoreticTransform(): NumberTheoreticTransform =
  result = NumberTheoreticTransform(base:1, rev: @[0, 1], rts: @[0, 1])
  assert(Mod >= 3 and Mod mod 2 == 1)
  var tmp = Mod - 1
  var max_base = 0
  while tmp mod 2 == 0: tmp = tmp shr 1; max_base.inc
  var root = 2
  while result.modPow(root, (Mod - 1) shr 1) == 1: root.inc
  assert(result.modPow(root, Mod - 1) == 1)
  root = result.modPow(root, (Mod - 1) shr max_base)
  result.max_base = max_base
  result.root = root

proc ensureBase(self: var NumberTheoreticTransform;nbase:int) =
  if nbase <= self.base: return
  self.rev.setLen(1 shl nbase)
  self.rts.setLen(1 shl nbase)
  for i in 0..<(1 shl nbase):
    self.rev[i] = (self.rev[i shr 1] shr 1) + ((i and 1) shl (nbase - 1))
  assert(nbase <= self.max_base)
  while self.base < nbase:
    let z = self.modPow(self.root, 1 shl (self.max_base - 1 - self.base))
    for i in (1 shl (self.base - 1))..<(1 shl self.base):
      self.rts[i shl 1] = self.rts[i]
      self.rts[(i shl 1) + 1] = self.mul(self.rts[i], z)
    self.base.inc

proc ntt(self: var NumberTheoreticTransform;a:var seq[int]) =
  let n = a.len
  assert((n and (n - 1)) == 0);
  let zeros = builtin_ctz(n)
  self.ensureBase(zeros)
  let shift = self.base - zeros;
  for i in 0..<n:
    if i < (self.rev[i] shr shift):
      swap(a[i], a[self.rev[i] shr shift])
  var k = 1
  while k < n:
    var i = 0
    while i < n:
      for j in 0..<k:
        let z = self.mul(a[i + j + k], self.rts[j + k])
        a[i + j + k] = self.add(a[i + j], Mod - z)
        a[i + j] = self.add(a[i + j], z)
      i += 2 * k
    k = k shl 1

proc multiply(self: var NumberTheoreticTransform;a,b:seq[int]):seq[int] =
  var (a,b) = (a,b)
  let need = a.len + b.len - 1;
  var nbase = 1
  while (1 shl nbase) < need: nbase.inc
  self.ensureBase(nbase)
  let sz = 1 shl nbase
  a.setLen(sz)
  b.setLen(sz)
  self.ntt(a)
  self.ntt(b)
  let inv_sz = self.inverse(sz)
  for i in 0..<sz: a[i] = self.mul(a[i], self.mul(b[i], inv_sz))
  a.reverse(1, a.len - 1)
  self.ntt(a)
  a.setLen(need)
  return a

#}}}
