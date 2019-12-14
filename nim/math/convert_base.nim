#{{{ toInt(seq[int], b = 10), toSeq(n: int, b = 10, min_digit)
proc toInt(d: seq[int], b = 10):int =
  result = 0
  var p = 1
  for di in d:
    result += p * di
    p *= b
proc toSeq(n: int, b = 10, min_digit = -1):seq[int] =
  result = newSeq[int]()
  var n = n
  while n > 0:result.add(n mod b); n = n div b
  if min_digit >= 0:
    while result.len < min_digit: result.add(0)
#}}}
