proc findFirst(f:(int)->bool, l, r:int):int =
  var (l, r) = (l, r)
  if f(l): return l
  while r - l > 1:
    let m = (l + r) div 2
    if f(m): r = m
    else: l = m
  return r
