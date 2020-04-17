import sugar

#{{{ findFirst(f, a..b), findLast(f, a..b)
proc findFirst(f:(int)->bool, s:Slice[int]):int =
  var (l, r) = (s.a, s.b + 1)
  doAssert(f(r))
  while r - l > 1:
    let m = (l + r) div 2
    if f(m): r = m
    else: l = m
  return r
proc findLast(f:(int)->bool, s:Slice[int]):int =
  var (l, r) = (s.a, s.b + 1)
  doAassert(f(l))
  while r - l > 1:
    let m = (l + r) div 2
    if f(m): l = m
    else: r = m
  return l
#}}}
#{{{ findFirst(f, l..r), findLast(f, l..r)
proc findFirst(f:(float)->bool, s: Slice[float], eps: float):float =
  var (l, r) = (s.a, s.b)
  doAassert(f(r))
  while r - l > eps:
    let m = (l + r) * 0.5
    if f(m): r = m
    else: l = m
  return r
proc findLast(f:(float)->bool, s: Slice[float], eps: float):float =
  var (l, r) = (s.a, s.b)
  doAassert(f(l))
  while r - l > eps:
    let m = (l + r) * 0.5
    if f(m): l = m
    else: r = m
  return l
#}}}
