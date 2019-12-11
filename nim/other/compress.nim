#{{{ Compress[T]
type Compress[T] = object
  xs: seq[T]
proc initCompress[T](xs:seq[T]):Compress[T] =
  result = Compress[T](xs:xs)
  result.build()
proc add[T](self:var Compress[T];t:T) =
  self.xs.add(t)
proc add[T](self:var Compress[T];v:seq[T]) =
  for t in v: self.add(t)
proc build[T](self:var Compress[T]) =
  self.xs.sort(cmp[T])
  self.xs = self.xs.deduplicate()
proc len[T](self:Compress[T]):int = self.xs.len
proc get[T](self:Compress[T], t:T):int =
  let i = self.xs.lowerBound(t)
  assert(self.xs[i] == t)
  return i
proc get[T](self:Compress[T], v:seq[T]):seq[int] =
  result = newSeq[int]()
  for t in v: result.add(self.get(t))
proc `[]`[T](self:Compress[T], k:int):T =
  return self.xs[k]
#}}}
