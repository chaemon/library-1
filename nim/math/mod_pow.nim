proc modPow[T](x,n,p:T):T =
  var (x,n) = (x,n)
  result = T(1)
  while n > 0:
    if (n and 1) > 0: result *= x; result = result mod p
    x *= x; x = x mod p
    n = (n shr 1)
