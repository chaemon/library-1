proc modSqrt[T](a, p:T):T =
  if a == 0: return 0
  if p == 2: return a
  if modPow(a, (p - 1) shr 1, p) != 1: return -1
  var b = T(1)
  while modPow(b, (p - 1) shr 1, p) == 1: b.inc
  var
    e = T(0)
    m = p - 1
  while m mod 2 == 0: m = m shr 1; e.inc
  var
    x = modPow(a, (m - 1) shr 1, p)
    y = a * (x * x mod p) mod p
  x = (x * a) mod p
  var z = modPow(b, m, p);
  while y != 1:
    var
      j = T(0)
      t = y
    while t != 1:
      j.inc
      t = (t * t) mod p
    z = modPow(z, T(1) shl (e - j - 1), p)
    x = (x * z) mod p
    z = (z * z) mod p
    y = (y * z) mod p
    e = j
  return x
