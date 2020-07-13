# FormalPowerSeries {{{
when not declared USE_FFT:
  const USE_FFT = true

type FieldElem = concept x, type T
  x + x
  x - x
  x * x
  x / x

import sugar, sequtils, strformat

type FormalPowerSeries[T:FieldElem] = seq[T]

proc initFormalPowerSeries[T:FieldElem](n:int):auto = FormalPowerSeries[T](newSeq[T](n))

template initFormalPowerSeries[T, S](data: openArray[S]):auto =
  when S is T: data
  else: data.mapIt(T(it))
proc `$`[T](self:FormalPowerSeries[T]):string = return self.mapIt($it).join(" ")

macro revise(a, b) =
  parseStmt(fmt"""let {a.repr} = if {a.repr} == -1: {b.repr} else: {a.repr}""")


#{{{ set mult, fft, sqrt
type
  SQRT[T] = proc(t:T):T

proc sqrtSub[T](self:FormalPowerSeries[T], update: bool, f:SQRT[T]):(bool, SQRT[T]){.discardable.} =
  var is_set{.global.} = false
  var sqr{.global.}:SQRT[T] = nil
  if update:
    is_set = true
    sqr = f
  return (is_set, sqr)
proc isSetSqrt[T](self:FormalPowerSeries[T]):bool = return self.sqrtSub(false, nil)[0]
proc setSqrt[T](self:FormalPowerSeries[T], f: SQRT[T]):SQRT[T]{.discardable.} = return self.sqrtSub(true, f)[1]
proc getSqrt[T](self:FormalPowerSeries[T]):SQRT[T]{.discardable.} = return self.sqrtSub(false, nil)[1]
#}}}

proc shrink[T](self: var FormalPowerSeries[T]) =
  while self.len > 0 and self[^1] == 0:
    discard self.pop()

#{{{ operators +=, -=, *=, mod=, -, /=
proc `+=`(self: var FormalPowerSeries, r:FormalPowerSeries) =
  if r.len > self.len: self.setlen(r.len)
  for i in 0..<r.len: self[i] += r[i]

proc `+=`[T](self: var FormalPowerSeries[T], r:T) =
  if self.len == 0: self.setlen(1)
  self[0] += r

proc `-=`[T](self: var FormalPowerSeries[T], r:FormalPowerSeries[T]) =
  if r.len > self.len: self.setlen(r.len)
  for i in 0..<r.len: self[i] -= r[i]
  self.shrink()

proc `-=`[T](self: var FormalPowerSeries[T], r:T) =
  if self.len == 0: self.setlen(1)
  self[0] -= r
  self.shrink()

proc `*=`[T](self: var FormalPowerSeries[T], v:T) =
  for t in self.mitems: t *= v

proc `*=`[T](self: var FormalPowerSeries[T],  r: FormalPowerSeries[T]) =
  if self.len == 0 or r.len == 0:
    self.setlen(0)
  else:
    when declared(BaseFFT):
      var fft = BaseFFT[T].init()
      self = fft.multiply(self, r)
    else:
      var c = initFormalPowerSeries[T](self.len + r.len - 1)
      for i in 0..<self.len:
        for j in 0..<r.len:
          c[i + j] += self[i] + r[j]
      self.swap(c)

proc `mod=`[T](self: var FormalPowerSeries[T], r:FormalPowerSeries[T]) = self -= self div r * r

proc `-`[T](self: FormalPowerSeries[T]):FormalPowerSeries[T] =
  var ret = self
  for i in 0..<self.len: ret[i] = -self[i]
  return ret
proc `/=`[T](self: var FormalPowerSeries[T], v:T) =
  for t in self.mitems: t /= v
#}}}

proc rev[T](self: FormalPowerSeries[T], deg = -1):auto =
  var ret = self
  if deg != -1: ret.setlen(deg)
  ret.reverse
  return ret

proc pre[T](self: FormalPowerSeries[T], sz:int):auto =
  result = self
  result.setlen(min(self.len, sz))

proc `div=`[T](self: var FormalPowerSeries[T], r: FormalPowerSeries[T]) =
  if self.len < r.len:
    self.setlen(0)
  else:
    let n = self.len - r.len + 1
    self = (self.rev().pre(n) * r.rev().inv(n)).pre(n).rev(n)

proc dot[T](self:FormalPowerSeries[T], r: FormalPowerSeries[T]):auto =
  var ret = initFormalPowerSeries[T](min(self.len, r.len))
  for i in 0..<ret.len: ret[i] = self[i] * r[i]
  return ret

proc `shr`[T](self: FormalPowerSeries[T], sz:int):auto =
  if self.len <= sz: return initFormalPowerSeries[T](0)
  result = self
  if sz >= 1: result.delete(0, sz - 1)

proc `shl`[T](self: FormalPowerSeries[T], sz:int):auto =
  result = initFormalPowerSeries[T](sz)
  result = result & self

proc diff[T](self: FormalPowerSeries[T]):auto =
  let n = self.len
  result = initFormalPowerSeries[T](max(0, n - 1))
  for i in 1..<n:
    result[i - 1] = self[i] * T(i)

proc integral[T](self: FormalPowerSeries[T]):auto =
  let n = self.len
  result = initFormalPowerSeries[T](n + 1)
  result[0] = T(0)
  for i in 0..<n: result[i + 1] = self[i] / T(i + 1)

# F(0) must not be 0
proc inv[T](self: FormalPowerSeries[T], deg = -1):auto =
  doAssert(self[0] != 0)
  deg.revise(self.len)
  when declared(BaseFFT):
    proc invFast[T](self: FormalPowerSeries[T]):auto =
      doAssert(self[0] != 0)
      let n = self.len
      var res = initFormalPowerSeries[T](1)
      res[0] = T(1) / self[0]
      var fft = BaseFFT[T].init()
      var d = 1
      while d < n:
        var f, g = initFormalPowerSeries[T](2 * d)
        for j in 0..<min(n, 2 * d): f[j] = self[j]
        for j in 0..<d: g[j] = res[j]
        when USE_FFT:
          var
            f1 = fft.fft(f)
            g1 = fft.fft(g)
          f1 = dot(f1, g1)
          f = fft.ifft(f1)
        else:
          f = f * g
        for j in 0..<d:
          f[j] = T(0)
          f[j + d] = -f[j + d]
        when USE_FFT:
          f1 = fft.fft(f)
          f1 = dot(f1, g1)
          f = fft.ifft(f1)
        else:
          f = f * g
        f[0..<d] = res[0..<d]
        res = f
        d = d shl 1
      return res.pre(n)
    var ret = self
    ret.setlen(deg)
    return ret.invFast()
  else:
    var ret = initFormalPowerSeries[T](1)
    ret[0] = T(1) / self[0]
    var i = 1
    while i < deg:
      ret = (ret + ret - ret * ret * self.pre(i shl 1)).pre(i shl 1)
      i = i shl 1
    return ret.pre(deg)

# F(0) must be 1
proc log[T](self:FormalPowerSeries[T], deg = -1):auto =
  doAssert self[0] == T(1)
  deg.revise(self.len)
  return (self.diff() * self.inv(deg)).pre(deg - 1).integral()

proc sqrt[T](self: FormalPowerSeries[T], deg = -1):auto =
  let n = self.len
  deg.revise(n)
  if self[0] == 0:
    for i in 1..<n:
      if self[i] != 0:
        if (i and 1) > 0: return initFormalPowerSeries[T](0)
        if deg - i div 2 <= 0: break
        result = (self shr i).sqrt(deg - i div 2)
        if result.len == 0: return initFormalPowerSeries[T](0)
        result = result shl (i div 2)
        if result.len < deg: result.setlen(deg)
        return
    return initFormalPowerSeries[T](deg)

  var ret:FormalPowerSeries[T]
  if self.isSetSqrt:
    let sqr = self.getSqrt()(self[0])
    if sqr * sqr != self[0]: return initFormalPowerSeries[T](0)
    ret = initFormalPowerSeries[T](@[T(sqr)])
  else:
    doAssert(self[0] == 1)
    ret = initFormalPowerSeries[T](@[T(1)])

  let inv2 = T(1) / T(2);
  var i = 1
  while i < deg:
    ret = (ret + self.pre(i shl 1) * ret.inv(i shl 1)) * inv2
    i = i shl 1
  return ret.pre(deg)

# F(0) must be 0
proc exp[T](self: FormalPowerSeries[T], deg = -1):auto =
  doAssert self[0] == 0
  deg.revise(self.len)
  when declared(BaseFFT):
    var fft = BaseFFT[T].init()
    proc onlineConvolutionExp[T](self: FormalPowerSeries[T], conv_coeff:FormalPowerSeries[T]):auto =
      let n = conv_coeff.len
      doAssert((n and (n - 1)) == 0)
      when USE_FFT:
        var conv_ntt_coeff = newSeq[FFTType]()
        var i = n
        while (i shr 1) > 0:
          var g = conv_coeff.pre(i)
          var g1 = fft.fft(g)
          conv_ntt_coeff.add(g1)
          i = i shr 1
      var conv_arg, conv_ret = initFormalPowerSeries[T](n)
      proc rec(l,r,d:int) =
        if r - l <= 16:
          for i in l..<r:
            var sum = T(0)
            for j in l..<i: sum += conv_arg[j] * conv_coeff[i - j]
            conv_ret[i] += sum
            conv_arg[i] = if i == 0: T(1) else: conv_ret[i] / i
        else:
          var m = (l + r) div 2
          rec(l, m, d + 1)
          var pre = initFormalPowerSeries[T](r - l)
          pre[0..<m-l] = conv_arg[l..<m]
          when USE_FFT:
            var pre1 = fft.fft(pre)
            pre1 = dot(pre1, conv_ntt_coeff[d])
            pre = fft.ifft(pre1)
          else:
            pre = fft.multiply(pre, conv_coeff.pre(n div 2^d))
          for i in 0..<r - m: conv_ret[m + i] += pre[m + i - l]
          rec(m, r, d + 1)
      rec(0, n, 0)
      return conv_arg
    proc expRec[T](self: FormalPowerSeries[T]):auto =
      doAssert self[0] == 0
      let n = self.len
      var m = 1
      while m < n: m *= 2
      var conv_coeff = initFormalPowerSeries[T](m)
      for i in 1..<n: conv_coeff[i] = self[i] * i
      return self.onlineConvolutionExp(conv_coeff).pre(n)
    var ret = self
    ret.setlen(deg)
    return ret.expRec()
  else:
    var ret = initFormalPowerSeries[T](@[T(1)])
    var i = 1
    while i < deg:
      ret = (ret * (self.pre(i shl 1) + T(1) - ret.log(i shl 1))).pre(i shl 1);
      i = i shl 1
    return ret.pre(deg)

proc pow[T](self: FormalPowerSeries[T], k:int, deg = -1):auto =
  let n = self.len
  deg.revise(n)
  for i in 0..<n:
    if self[i] != T(0):
      let rev = T(1) / self[i]
      var ret = (((self * rev) shr i).log() * T(k)).exp() * (self[i]^k)
      if i * k > deg: return initFormalPowerSeries[T](deg)
      ret = (ret shl (i * k)).pre(deg)
      if ret.len < deg:
        ret.setlen(deg)
      return ret
  return self

proc eval[T](self: FormalPowerSeries[T], x:T):T =
  var
    r = T(0)
    w = T(1)
  for v in self:
    r += w * v
    w *= x
  return r

proc powMod[T](self: FormalPowerSeries[T], n:int, M:FormalPowerSeries[T]):auto =
  let modinv = M.rev().inv()
  proc getDiv(base:FormalPowerSeries[T]):FormalPowerSeries[T] =
    var base = base
    if base.len < M.len:
      base.setlen(0)
      return base
    let n = base.len - M.len + 1
    return (base.rev().pre(n) * modinv.pre(n)).pre(n).rev(n)
  var
    n = n
    x = self
    ret = initFormalPowerSeries[T](@[T(1)])
  while n > 0:
    if (n and 1) > 0:
      ret *= x
      ret -= getDiv(ret) * M
    x *= x
    x -= getDiv(x) * M
    n = n shr 1
  return ret

# operators +, -, *, div, mod {{{
proc `+`[T](self:FormalPowerSeries[T];r:FormalPowerSeries[T]):FormalPowerSeries[T] = result = self;result += r
proc `+`[T](self:FormalPowerSeries[T];v:T):FormalPowerSeries[T] = result = self;result += v
proc `-`[T](self:FormalPowerSeries[T];r:FormalPowerSeries[T]):FormalPowerSeries[T] = result = self;result -= r
proc `-`[T](self:FormalPowerSeries[T];v:T):FormalPowerSeries[T] = result = self;result -= v
proc `*`[T](self:FormalPowerSeries[T];r:FormalPowerSeries[T]):FormalPowerSeries[T] = result = self;result *= r
proc `*`[T](self:FormalPowerSeries[T];v:T):FormalPowerSeries[T] = result = self;result *= v
proc `div`[T](self:FormalPowerSeries[T];r:FormalPowerSeries[T]):FormalPowerSeries[T] = result = self;result.`div=` (r)
proc `mod`[T](self:FormalPowerSeries[T];r:FormalPowerSeries[T]):FormalPowerSeries[T] = result = self;result.`mod=` (r)
# }}}
# }}}
