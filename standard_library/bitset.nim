#{{{ bitset
import strutils, sequtils, algorithm

const BitWidth = 64

proc toBin(b:uint64, n: int): string =
  result = ""
  for i in countdown(n-1, 0):
    if (b and (1'u64 shl uint64(i))) != 0'u64: result &= "1"
    else: result &= "0"

type StaticBitSet[N:static[int]] = ref object
  data: array[(N + BitWidth - 1) div BitWidth, uint64]

proc initStaticBitSet[N:static[int]](): StaticBitSet[N] =
  const size = (N + BitWidth - 1) div BitWidth
  var data: array[size, uint64]
  return StaticBitSet[N](data: data)
proc initStaticBitSet1[N:static[int]](): StaticBitSet[N] =
  result = initStaticBitSet(N)
  let
    q = (N + BitWidth - 1) div BitWidth
    r = N div BitWidth
  for i in 0..<q:result.data[i] = (not 0'u64)
  if r > 0:result.data[q] = ((1'u64 shl uint64(r)) - 1)

proc `not`[N:static[int]](a: StaticBitSet[N]): StaticBitSet[N] =
  result = initStaticBitSet1[N]()
  for i in 0..<a.data.len: result.data[i] = (not a.data[i]) and result.data[i]
proc `or`[N:static[int]](a, b: StaticBitSet[N]): StaticBitSet[N] =
  result = initStaticBitSet[N]()
  for i in 0..<a.data.len: result.data[i] = a.data[i] or b.data[i]
proc `and`[N:static[int]](a, b: StaticBitSet[N]): StaticBitSet[N] =
  result = initStaticBitSet[N]()
  for i in 0..<a.data.len: result.data[i] = a.data[i] and b.data[i]
proc `xor`[N:static[int]](a, b: StaticBitSet[N]): StaticBitSet[N] =
  result = initStaticBitSet[N]()
  for i in 0..<a.data.len: result.data[i] = a.data[i] xor b.data[i]

proc `$`[N:static[int]](a: StaticBitSet[N]):string =
  var
    q = N div BitWidth
    r = N mod BitWidth
  var v = newSeq[string]()
  for i in 0..<q: v.add(a.data[i].toBin(BitWidth))
  if r > 0: v.add(a.data[q].toBin(r))
  v.reverse()
  return v.join("")

proc any[N:static[int]](a: StaticBitSet[N]): bool = 
  var
    q = N div BitWidth
    r = N mod BitWidth
  for i in 0..<q:
    if a.data[i] != 0.uint64: return true
  if r > 0 and (a.data[^1] and setBits[uint64](r)) != 0.uint64: return true
  return false

proc all[N:static[int]](a: StaticBitSet[N]): bool =
  var
    q = N div BitWidth
    r = N mod BitWidth
  for i in 0..<q:
    if (not a.data[i]) != 0.uint64: return false
  if r > 0 and a.data[^1] != setBits[uint64](r): return false
  return true

proc `[]`[N:static[int]](b:StaticBitSet[N],n:int):int =
  assert 0 <= n and n < N
  let
    q = n div BitWidth
    r = n mod BitWidth
  return b.data[q][r]
proc `[]=`[N:static[int]](b:var StaticBitSet[N],n:int,t:int) =
  assert 0 <= n and n < N
  assert t == 0 or t == 1
  let
    q = n div BitWidth
    r = n mod BitWidth
  b.data[q][r] = t

proc `shl`[N:static[int]](a: StaticBitSet[N], n:int): StaticBitSet[N] =
  result = initStaticBitSet[N]()
  var r = int(n mod BitWidth)
  if r < 0: r += BitWidth
  let q = (n - r) div BitWidth
  let maskl = setBits[uint64](BitWidth - r)
  for i in 0..<a.data.len:
    let d = (a.data[i] and maskl) shl uint64(r)
    let i2 = i + q
    if 0 <= i2 and i2 < a.data.len: result.data[i2] = result.data[i2] or d
  if r != 0:
    let maskr = setBits[uint64](r) shl uint64(BitWidth - r)
    for i in 0..<a.data.len:
      let d = (a.data[i] and maskr) shr uint64(BitWidth - r)
      let i2 = i + q + 1
      if 0 <= i2 and i2 < a.data.len: result.data[i2] = result.data[i2] or d
  block:
    let r = a.N mod BitWidth
    if r != 0:
      let mask = not (setBits[uint64](BitWidth - r) shl uint64(r))
      result.data[^1] = result.data[^1] and mask
proc `shr`[N:static[int]](a: StaticBitSet[N], n:int): StaticBitSet[N] = a shl (-n)
#}}}
