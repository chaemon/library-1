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
proc initMint[T](a:T):Mint[Mod] = initMint(a, MOD)
proc init[T](self:Mint[Mod], a:T):Mint[Mod] = initMint(a, Mod)
proc Identity(self:Mint[Mod]):Mint[Mod] = return initMint(1, Mod)

proc `==`(a:Mint[Mod], b:Mint[Mod]):bool = a.v == b.v
proc `!=`(a:Mint[Mod], b:Mint[Mod]):bool = a.v != b.v
proc `-`(self:Mint[Mod]):Mint[Mod] =
  if self.v == 0: return self
  else: return Mint[Mod](v:MOD - self.v)
proc `$`(a:Mint[Mod]):string = return $(a.v)

proc `+=`[T](self:var Mint[Mod]; a:T):void =
  self.v += initMint(a, Mod).v
  if self.v >= MOD: self.v -= MOD
proc `-=`[T](self:var Mint[Mod],a:T):void =
  self.v -= initMint(a, Mod).v
  if self.v < 0: self.v += MOD
proc `*=`[T](self:var Mint[Mod],a:T):void =
  self.v *= initMint(a, Mod).v
  self.v = self.v mod MOD
proc `^=`(self:var Mint[Mod], n:int) =
  var (x,n,a) = (self,n,self.Identity)
  while n > 0:
    if (n and 1) > 0: a *= x
    x *= x
    n = (n shr 1)
  swap(self, a)
proc inverse(x:int):Mint[Mod] =
  var (a, b) = (x, MOD)
  var (u, v) = (1, 0)
  while b > 0:
    let t = a div b
    a -= t * b;swap(a,b)
    u -= t * v;swap(u,v)
  return initMint(u, Mod)
proc `/=`[T](a:var Mint[Mod],b:T):void = a *= initMint(b, Mod).v.inverse()
proc `+`[T](a:Mint[Mod],b:T):Mint[Mod] = result = a;result += b
proc `-`[T](a:Mint[Mod],b:T):Mint[Mod] = result = a;result -= b
proc `*`[T](a:Mint[Mod],b:T):Mint[Mod] = result = a;result *= b
proc `/`[T](a:Mint[Mod],b:T):Mint[Mod] = result = a; result /= b
proc `^`(a:Mint[Mod],b:int):Mint[Mod] = result = a; result ^= b
#}}}
