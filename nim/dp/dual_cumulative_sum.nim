# CumulativeSum (Imos){{{
import sequtils

type DualCumulativeSum[T] = object
  built:bool
  data: seq[T]

proc initDualCumulativeSum[T](sz:int = 100):DualCumulativeSum[T] = DualCumulativeSum[T](data: newSeqWith(sz, T(0)), built:false)
proc initDualCumulativeSum[T](data:seq[T]):DualCumulativeSum[T] =
  result = DualCumulativeSum[T](data: data, built:false)
  result.build()
proc add[T](self: var DualCumulativeSum[T], s:Slice[int], x:T) =
  assert(not self.built)
  if self.data.len <= s.b + 1:
    self.data.setlen(s.b + 1)
  self.data[s.a] += x
  self.data[s.b + 1] -= x

proc build[T](self: var DualCumulativeSum[T]) =
  assert(not self.built)
  self.built = true
  self.data[0] = T(0)
  for i in 1..<self.data.len:
    self.data[i] += self.data[i - 1];

proc `[]`[T](self: DualCumulativeSum[T], k:int):T =
  assert(self.built)
  if k < 0: return T(0)
  return self.data[min(k, self.data.len - 1)]
#}}}
