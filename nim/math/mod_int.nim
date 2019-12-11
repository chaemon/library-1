const MOD = 1_000_000_007

#{{{ Mint[Mod]
proc getDefault(T:typedesc): T = (var temp:T;temp)
proc getDefault[T](x:T): T = (var temp:T;temp)

type Mint[Mod: static[int]] = object
  v:int
proc initMint[T](a:T, Mod: static[int]):Mint[Mod] =
  when T is Mint[Mod]:
    return a
  else:
    var a = a
    a = a mod Mod
    if a < 0: a += Mod
    result.v = a
#    return Mint[Mod](v:a)
proc initMint[T](a:T):Mint[Mod] = initMint(a, MOD)
proc init[T](self:Mint[Mod], a:T):Mint[Mod] = initMint(a, Mod)
proc Identity(self:Mint[Mod]):Mint[Mod] = return initMint(1, Mod)
proc `+=`[T](a:var Mint[Mod], b:T):void =
  a.v += initMint(b, Mod).v
  if a.v >= MOD:
    a.v -= MOD
proc `+`[T](a:Mint[Mod],b:T):Mint[Mod] =
  var c = a
  c += b
  return c
proc `*=`[T](a:var Mint[Mod],b:T):void =
  a.v *= initMint(b, Mod).v
  a.v = a.v mod MOD
proc `*`[T](a:Mint[Mod],b:T):Mint[Mod] =
  var c = a
  c *= b
  return c
proc `-`(a:Mint[Mod]):Mint[Mod] =
  if a.v == 0: return a
  else: return Mint[Mod](v:MOD - a.v)
proc `-=`[T](a:var Mint[Mod],b:T):void =
  a.v -= initMint(b, Mod).v
  if a.v < 0:
    a.v += MOD
proc `-`[T](a:Mint[Mod],b:T):Mint[Mod] =
  var c = a
  c -= b
  return c
proc `$`(a:Mint[Mod]):string =
  return $(a.v)
proc `==`(a:Mint[Mod], b:Mint[Mod]):bool = a.v == b.v
proc `!=`(a:Mint[Mod], b:Mint[Mod]):bool = a.v != b.v
proc pow(x:Mint[Mod], n:int):Mint[Mod] =
  var (x,n) = (x,n)
  result = initMint(1, Mod)
  while n > 0:
    if (n and 1) > 0: result *= x
    x *= x
    n = (n shr 1)
proc inverse(x:int):Mint[Mod] =
  var (a, b) = (x, MOD)
  var (u, v) = (1, 0)
  while b > 0:
    let t = a div b
    a -= t * b;swap(a,b)
    u -= t * v;swap(u,v)
  return initMint(u, Mod)
proc `/=`[T](a:var Mint[Mod],b:T):void =
  a *= initMint(b, Mod).v.inverse()
proc `/`[T](a:Mint[Mod],b:T):Mint[Mod] =
  var c = a
  c /= b
  return c
#}}}
