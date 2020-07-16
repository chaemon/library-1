# modSqrt {{{
import options

proc modSqrt[ModInt](a:ModInt):Option[ModInt] =
  let p = a.getMod()
  if a == 0: return ModInt(0).some
  if p == 2: return ModInt(a).some
  if a ^ ((p - 1) shr 1) != 1: return none(ModInt)
  var b = ModInt(1)
  while b ^ ((p - 1) shr 1) == 1: b += 1
  var
    e = 0
    m = p - 1
  while m mod 2 == 0: m = m shr 1; e.inc
  var
    x = a ^ ((m - 1) shr 1)
    y = a * x * x
  x *= a
  var z = b ^ m
  while y != 1:
    var
      j = 0
      t = y
    while t != 1:
      j.inc
      t *= t
    z = z ^ (1 shl (e - j - 1))
    x *= z
    z *= z
    y *= z
    e = j
  return ModInt(x).some
#}}}
