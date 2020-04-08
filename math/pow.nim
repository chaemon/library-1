#{{{ pow[T]: Identity and *= must be defined
#proc Identity(self: seq[int]): seq[int] =
#  return lc[i | (i <- 0..<self.len), int]

proc `^=`[T](self: var T, k:int) =
  var k = k
  var B = self.Identity()
  while k > 0:
    if (k and 1) > 0: B *= self
    self *= self;k = k shr 1
  self.swap(B)

proc `^`[T](self: T, k:int):T =
  result = self;result ^= k
#}}}
