# CumulativeSum {{{
import sequtils

type CumulativeSum[T] = object
  data: seq[T]

proc initCumulativeSum[T](sz:int):CumulativeSum[T] = CumulativeSum[T](data: newSeqWith(sz, T(0)))
proc add[T](self: var CumulativeSum[T], k:int, x:T) =
  self.data[k] += x

proc build[T](self: var CumulativeSum[T]) =
  for i in 1..<self.data.len:
    self.data[i] += self.data[i - 1];

proc `[]`[T](self: CumulativeSum[T], k:int):T =
  if k < 0: return T(0)
  return self.data[min(k, self.data.len - 1)]
proc `[]`[T](self: CumulativeSum[T], s:Slice[int]):T =
  if s.a > s.b: return T(0)
  return self[s.b] - self[s.a - 1]
#}}}
