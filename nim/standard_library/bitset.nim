#{{{ bitset
import strutils, sequtils, algorithm

let BitWidth = 64

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
