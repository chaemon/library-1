import sequtils
import algorithm

type Compress[T] = object
  xs: seq[T]

proc newCompless[T](xs:seq[T]):Compress[T] =
  return Compress[T](xs:xs)

proc add[T](self:var Compress[T];t:T) =
  self.xs.add(t)
proc add[T](self:var Compress[T];v:seq[T]) =
  for t in v: self.add(t)

proc build[T](self:var Compress[T]) =
  self.xs.sort(cmp[T])
  self.xs = self.xs.deduplicate()

proc get[T](self:Compress[T], t:T):int =
  return self.xs.lowerBound(t)
proc get[T](self:Compress[T], v:seq[T]):seq[int] =
  result = newSeq[int]()
  for t in v: result.add(self.get(t))
proc `[]`[T](self:Compress[T], k:int):T =
  return self.xs[k]
