# CumulativeSum {{{
import sequtils

type CumulativeSum[T] = object
  pos:int
  data: seq[T]

proc initCumulativeSum[T]():CumulativeSum[T] = CumulativeSum[T](data: newSeqWith(1, T().init(0)), pos:0)
proc `[]=`[T](self: var CumulativeSum[T], k:int, x:T) =
  if k < self.pos: doAssert(false)
  if self.data.len < k + 2:
    self.data.setlen(k + 2)
  for i in self.pos+1..<k:
    self.data[i + 1] = self.data[i]
  self.data[k + 1] = self.data[k] + x
  self.pos = k

proc initCumulativeSum[T](data:seq[T]):CumulativeSum[T] =
  result = initCumulativeSum[T]()
  for i,d in data: result[i] = d

proc sum[T](self: CumulativeSum[T], k:int):T =
  if k < 0: return T().init(0)
  return self.data[min(k, self.data.len - 1)]
proc `[]`[T](self: CumulativeSum[T], s:Slice[int]):T =
  if s.a > s.b: return T().init(0)
  return self.sum(s.b + 1) - self.sum(s.a)
#}}}
