proc modLog(a, b, p:int):int =
  var
    g = 1
    i = p
    b = b
  while i > 0:
    g = (g * a) mod p
    i = i div 2
  g = gcd(g, p)

  var
    t = 1
    c = 0
  while t mod g > 0:
    if t == b: return c
    t = (t * a) mod p
    c += 1
  if b mod g > 0: return -1

  t = t div g
  b = b div g

  var
    n = p div g
    h = 0
    gs = 1

  while h * h < n:
    gs = (gs * a) mod n
    h += 1

  var
    bs = initTable[int,int]()
    s = 0
    e = b
  while s < h:
    e = (e * a) mod n
    s += 1
    bs[e] = s

  s = 0
  e = t
  while s < n:
    e = (e * gs) mod n
    s += h
    if e in bs: return c + s - bs[e]
  return -1
