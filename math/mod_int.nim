# ModInt {{{
# ModInt[Mod] {{{
type ModInt[Mod: static[int]] = object
  v:int32

proc initModInt(a:SomeInteger, Mod:static[int]):ModInt[Mod] =
  var a = a.int
  a = a mod Mod
  if a < 0: a += Mod
  result.v = a.int32

macro declareModInt(Mod:static[int], t: untyped):untyped =
  var strBody = ""
  strBody &= fmt"""
type {t.repr} = ModInt[{Mod.repr}]
converter to{t.repr}(a:SomeInteger):{t.repr} = initModInt(a, {Mod.repr})
proc init{t.repr}(a:SomeInteger):{t.repr} = initModInt(a, {Mod.repr})
proc `$`(a:{t.repr}):string = $(a.v)
"""
  parseStmt(strBody)

when declared(Mod): declareModInt(Mod, Mint)
##}}}

# ModIntDynamic {{{
type DMint = object
  v:int32

proc setModSub(self:typedesc, m:int = -1, update = false):int32 {.discardable.} =
  var DMOD {.global.}:int32
  if update: DMOD = m.int32
  return DMOD

proc fastMod(a:int,m:uint32):uint32{.inline.} =
  var
    minus = false
    a = a
  if a < 0:
    minus = true
    a = -a
  elif a < m.int:
    return a.uint32
  var
    xh = (a shr 32).uint32
    xl = a.uint32
    d:uint32
  asm """
    "divl %4; \n\t"
    : "=a" (`d`), "=d" (`result`)
    : "d" (`xh`), "a" (`xl`), "r" (`m`)
  """
  if minus and result > 0'u32: result = m - result
proc initDMint(a:SomeInteger, Mod:int):DMint =
  var a = fastMod(a.int, Mod.uint32).int
  result.v = a.int32
#}}}

# Operations {{{
type ModIntC = concept x, type T
  x.v

proc getMod[T](self: T):int32 =
  when T is ModInt:
    return T.Mod
  else:
    return T.type.setModSub()
proc getMod(self: typedesc):int32 =
  when self is ModInt:
    return self.Mod
  else:
    return self.setModSub()

proc setMod(self: typedesc, m:int) =
  self.setModSub(m, true)

proc Identity(self:ModIntC):auto = result = self;result.v = 1
proc makeModInt[Mod:static[int], T](self:ModInt[Mod], a:T):ModInt[Mod] =
  when a is ModInt[Mod]:
    return a
  else:
    initModInt(a, Mod)

proc makeModInt[T](self:ModIntC and not ModInt, a:T):typeof(self) =
  when a is self.type:
    a
  else:
    (var r = self.type.default;r.v = fastMod(a.int, self.getMod().uint32).int32;r)

macro declareDMintConverter(t:untyped) =
  parseStmt(fmt"""
converter to{t.repr}(a:int):{t.repr} =
  let Mod = {t.repr}.getMod()
  if Mod > 0:
    result.v = fastMod(a.int, Mod.uint32).int32
  else:
    result.v = a.int32
    doAssert(false)
  return result
""")

declareDMintConverter(DMint)

macro declareDMint(t:untyped) =
  parseStmt(fmt"""
type {t.repr} {{.borrow: `.`.}} = distinct DMint
declareDMintConverter({t.repr})
""")

proc `*=`[T](self:var ModIntC, a:T) =
  when self is ModInt:
    self.v = (self.v.int * self.makeModInt(a).v.int mod self.getMod().int).int32
  else:
    self.v = fastMod(self.v.int * self.makeModInt(a).v.int, self.getMod().uint32).int32
proc `==`[T](a:ModIntC, b:T):bool = a.v == a.makeModInt(b).v
proc `!=`[T](a:ModIntC, b:T):bool = a.v != a.makeModInt(b).v
proc `-`(self:ModIntC):auto =
  if self.v == 0: return self
  else: return self.makeModInt(self.getMod() - self.v)
proc `$`(a:ModIntC):string = return $(a.v)

proc `+=`[T](self:var ModIntC; a:T) =
  self.v += self.makeModInt(a).v
  if self.v >= self.getMod(): self.v -= self.getMod()
proc `-=`[T](self:var ModIntC, a:T) =
  self.v -= self.makeModInt(a).v
  if self.v < 0: self.v += self.getMod()
proc `^=`(self:var ModIntC, n:int) =
  var (x,n,a) = (self,n,self.Identity)
  while n > 0:
    if (n and 1) > 0: a *= x
    x *= x
    n = (n shr 1)
  swap(self, a)
proc inverse(self: ModIntC):auto =
  var
    a = self.v.int
    b = self.getMod().int
    u = 1
    v = 0
  while b > 0:
    let t = a div b
    a -= t * b;swap(a, b)
    u -= t * v;swap(u, v)
  return self.makeModInt(u)
proc `/=`[T](a:var ModIntC,b:T) =
  a *= a.makeModInt(b).inverse()
proc `+`[T](a:ModIntC,b:T):auto = result = a;result += b
proc `-`[T](a:ModIntC,b:T):auto = result = a;result -= b
proc `*`[T](a:ModIntC,b:T):auto = result = a;result *= b
proc `/`[T](a:ModIntC,b:T):auto = result = a;result /= b
proc `^`(a:ModIntC,b:int):auto = result = a;result ^= b
# }}}
# }}}
