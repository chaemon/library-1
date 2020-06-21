# enumerate_digits {{{
proc nextDigits(a:var seq[int], d:seq[int]):bool =
  doAssert(a.len == d.len)
  for i in 0..<a.len:
    a[i].inc
    if a[i] < d[i]:
      return true
    doAssert(a[i] == d[i])
    a[i] = 0
    if i == a.len - 1: return false

proc nextDigits(a:var seq[int], d:int):bool =
  for i in 0..<a.len:
    a[i].inc
    if a[i] < d:
      return true
    doAssert(a[i] == d)
    a[i] = 0
    if i == a.len - 1: return false

iterator enumerateDigits(n, d:int):seq[int] =
  var
    a = newSeq[int](n)
  while true:
    yield a
    if not a.nextDigits(d):
      break
# }}}
