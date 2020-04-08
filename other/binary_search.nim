import future

#{{{ findFirst(f, a..b), findLast(f, a..b)
proc findFirst(f:(int)->bool, s:Slice[int]):int =
  var (l, r) = (s.a, s.b + 1)
  while r - l > 1:
    let m = (l + r) div 2
    if f(m): r = m
    else: l = m
  return r
proc findLast(f:(int)->bool, s:Slice[int]):int =
  var (l, r) = (s.a, s.b + 1)
  if not f(l): return -1
  while r - l > 1:
    let m = (l + r) div 2
    if f(m): l = m
    else: r = m
  return l
#}}}
#{{{ findFirst(f, l, r), findLast(f, l, r)
proc findFirst(f:(float)->bool, l, r: float, eps: float):float =
  var (l, r) = (l, r)
  while r - l > eps:
    let m = (l + r) / 2.0
    if f(m): r = m
    else: l = m
  return r
proc findLast(f:(float)->bool, l, r: float, eps: float):float =
  var (l, r) = (l, r)
  if not f(l): return -float(Inf)
  while r - l > eps:
    let m = (l + r) / 2.0
    if f(m): l = m
    else: r = m
  return l
#}}}
