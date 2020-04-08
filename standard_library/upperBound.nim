proc upperBound*[T](a: openArray[T], key: T): int =
  result = a.low
  var count = a.high - a.low + 1
  var step, pos: int
  while count != 0:
    step = count shr 1
    pos = result + step
    if a[pos] <= key:
      result = pos + 1
      count -= step + 1
    else:
      count = step
