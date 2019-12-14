import sequtils

type CumulativeSum[T] = object
  data: seq[T]

proc initCumulativeSum[T](sz:int) = CumulativeSum[T](data: newSeqWith(sz, T(0)))

proc add[T](self: var CumulativeSum[T], k:int, x:T) =
  self.data[k] += x

proc build[T](self: var CumulativeSum[T]) =
  for i in 1..<data.len:
    self.data[i] += self.data[i - 1];

proc query[T](self: CumulativeSum[T], k:int):T =
  if k < 0: return T(0)
  return self.data[min(k, self.data.len - 1)]
