import sequtils, math

type SparseTable[T] = object
  data: seq[seq[T]]
  lookup: seq[int]
  f: (T,T)->T

proc initSparseTable[T](v:seq[T], f:(T,T)->T):SparseTable[T] =
  var b = 0
  while 2^b <= v.len: b += 1
  var data = newSeqWith(b, newSeq[T](2 ^ b))
  for i in 0..<v.len: data[0][i] = v[i]
  for i in 1..<b:
    var j = 0
    while j + 2^i <= 2^b:
      data[i][j] = f(data[i - 1][j], data[i - 1][j + (2^(i - 1))]);
      j += 1
  var lookup = newSeq[int](v.len + 1)
  for i in 2..<lookup.len: lookup[i] = lookup[i shr 1] + 1
  return SparseTable[T](data:data, lookup:lookup, f:f)

proc rmq[T](self: SparseTable[T], s:Slice[int]):T {.inline.}=
  let b = self.lookup[s.b + 1 - s.a];
  return self.f(self.data[b][s.a], self.data[b][s.b + 1 - 2^b])
