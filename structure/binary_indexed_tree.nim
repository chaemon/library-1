type BinaryIndexedTree[T] = object
  data: seq[T]

proc initBinaryIndexedTree[T](sz:int):BinaryIndexedTree[T] = BinaryIndexedTree[T](data:newSeq[T](sz + 1))

proc sum[T](self:BinaryIndexedTree[T], k:int):T =
  var
    k = k + 1
    ret = T(0)
  while k > 0:
    ret += self.data[k]
    k -= (k and (-k))
  return ret

proc add[T](self: var BinaryIndexedTree[T], k:int, x:T) =
  var k = k + 1
  while k < self.data.len:
    self.data[k] += x
    k += (k and (-k))
