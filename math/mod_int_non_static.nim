var MOD:int

#{{{ ModInt
proc getDefault(T:typedesc): T = (var temp:T;temp)
proc getDefault[T](x:T): T = (var temp:T;temp)

type ModInt = object
  v:int32
proc initModInt[T](a:T):ModInt =
  when T is ModInt:
    return a
  else:
    var a = a
    if MOD > 0:
      a = a mod MOD
      if a < 0: a += MOD
    result.v = a.int32
proc init[T](self:ModInt, a:T):ModInt = initModInt(a)
proc Identity(self:ModInt):ModInt = return initModInt(1)

proc `==`[T](a:ModInt, b:T):bool = a.v == a.init(b).v
proc `!=`[T](a:ModInt, b:T):bool = a.v != a.init(b).v
proc `-`(self:ModInt):ModInt =
  if self.v == 0.int32: return self
  else: return ModInt(v:MOD.int32 - self.v)
proc `$`(a:ModInt):string = return $(a.v)

proc `+=`[T](self:var ModInt; a:T):void =
  self.v += initModInt(a).v
  if self.v >= MOD: self.v -= MOD.int32
proc `-=`[T](self:var ModInt,a:T):void =
  self.v -= initModInt(a).v
  if self.v < 0: self.v += MOD.int32
proc `*=`[T](self:var ModInt,a:T):void =
  self.v = ((self.v.int * initModInt(a).v.int) mod MOD).int32
proc `^=`(self:var ModInt, n:int) =
  var (x,n,a) = (self,n,self.Identity)
  while n > 0:
    if (n and 1) > 0: a *= x
    x *= x
    n = (n shr 1)
  swap(self, a)
proc inverse(x:int):ModInt =
  var (a, b) = (x, MOD)
  var (u, v) = (1, 0)
  while b > 0:
    let t = a div b
    a -= t * b;swap(a,b)
    u -= t * v;swap(u,v)
  return initModInt(u)
proc `/=`[T](a:var ModInt,b:T):void = a *= initModInt(b).v.inverse()
proc `+`[T](a:ModInt,b:T):ModInt = result = a;result += b
proc `-`[T](a:ModInt,b:T):ModInt = result = a;result -= b
proc `*`[T](a:ModInt,b:T):ModInt = result = a;result *= b
proc `/`[T](a:ModInt,b:T):ModInt = result = a; result /= b
proc `^`(a:ModInt,b:int):ModInt = result = a; result ^= b
#}}}

type Mint = ModInt
proc initMint[T](a:T):ModInt = initModInt(a)
