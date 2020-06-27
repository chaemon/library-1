import sugar, sequtils

type
  FormalPowerSeries[T] = object
    data: seq[T]

proc `[]`[T](self:FormalPowerSeries[T], i:int or BackwardsIndex):T = self.data[i]
proc `[]=`[T](self:var FormalPowerSeries[T], i:int or BackwardsIndex, t:T) = self.data[i] = t

proc initFormalPowerSeries[T](n:int):auto = FormalPowerSeries[T](data:newSeq[T](n))
proc initFormalPowerSeries[T](data: seq[T]):auto = FormalPowerSeries[T](data:data)

proc `$`[T](self:FormalPowerSeries[T]):string =
  return self.data.mapIt($it).join(" ")

#{{{ set mult, fft, sqrt
type
  MULT[T] = proc(a,b:FormalPowerSeries[T]):FormalPowerSeries[T]
  FFT[T] = proc(a:var FormalPowerSeries[T]):void
  SQRT[T] = proc(t:T):T

proc multSub[T](self:FormalPowerSeries[T], update: bool, f:MULT[T]):MULT[T]{.discardable.} =
  var is_set{.global.} = false
  var mult{.global.}:MULT[T] = nil
  if update:
    is_set = true
    mult = f
  return mult
template setMult[T](self:FormalPowerSeries[T], u):MULT[T] =
  self.multSub(true, proc(a,b:FormalPowerSeries[T]):FormalPowerSeries[T] = initFormalPowerSeries[T](u.multiply(a.data, b.data)))
proc getMult[T](self:FormalPowerSeries[T]):MULT[T]{.discardable.} = return self.multSub(false, nil)
proc FFTSub[T](self:FormalPowerSeries[T], update: bool, f, g:FFT[T]):(bool, FFT[T], FFT[T]) {.discardable.} =
  var is_set{.global.} = false
  var fft{.global.}:FFT[T] = nil
  var ifft{.global.}:FFT[T] = nil
  if update:
    is_set = true
    fft = f
    ifft = g
  return (is_set, fft, ifft)

template setFFT[T](self:FormalPowerSeries[T], u) =
  self.FFTSub(true, proc(a:var FormalPowerSeries[T]) = u.fft(a.data), proc(a:var FormalPowerSeries[T]) = u.ifft(a.data))
proc isSetFFT[T](self:FormalPowerSeries[T]):bool = return self.FFTSub(false, nil, nil)[0]
proc getFFT[T](self:FormalPowerSeries[T]):auto {.discardable.} = return self.FFTSub(false, nil, nil)

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
  while self.data.len > 0 and self.data[^1] == 0:
    discard self.data.pop()

#{{{ operators +=, -=, *=, mod=, -, /=
proc `+=`[T](self: var FormalPowerSeries[T], r:FormalPowerSeries[T]) =
  if r.data.len > self.data.len: self.data.setlen(r.data.len)
  for i in 0..<r.data.len: self.data[i] += r.data[i]

proc `+=`[T](self: var FormalPowerSeries[T], r:T) =
  if self.data.len == 0: self.data.setlen(1)
  self.data[0] += r

proc `-=`[T](self: var FormalPowerSeries[T], r:FormalPowerSeries[T]) =
  if r.data.len > self.data.len: self.data.setlen(r.data.len)
  for i in 0..<r.data.len: self.data[i] -= r.data[i]
  self.shrink()

proc `-=`[T](self: var FormalPowerSeries[T], r:T) =
  if self.data.len == 0: self.data.setlen(1)
  self.data[0] -= r
  self.shrink()

proc `*=`[T](self: var FormalPowerSeries[T], v:T) =
  for t in self.data.mitems: t *= v

proc `*=`[T](self: var FormalPowerSeries[T],  r: FormalPowerSeries[T]) =
  if self.data.len == 0 or r.data.len == 0:
    self.data.setlen(0)
  else:
    self = (self.getMult)(self, r)

proc `mod=`[T](self: var FormalPowerSeries[T], r:FormalPowerSeries[T]) = self -= self div r * r

proc `-`[T](self: FormalPowerSeries[T]):FormalPowerSeries[T] =
  var ret = self
  for i in 0..<self.data.len: ret.data[i] = -self.data[i]
  return ret
proc `/=`[T](self: var FormalPowerSeries[T], v:T) =
  for t in self.data.mitems: t /= v
#}}}

proc rev[T](self: FormalPowerSeries[T], deg = -1):auto =
  var ret = self
  if deg != -1: ret.data.setlen(deg)
  ret.data.reverse
  return ret

proc pre[T](self: FormalPowerSeries[T], sz:int):auto =
  result = self
  result.data.setlen(min(self.data.len, sz))

proc `div=`[T](self: var FormalPowerSeries[T], r: FormalPowerSeries[T]) =
  if self.data.len < r.data.len:
    self.data.setlen(0)
  else:
    let n = self.data.len - r.data.len + 1
    self = (self.rev().pre(n) * r.rev().inv(n)).pre(n).rev(n)

proc dot[T](self:FormalPowerSeries[T], r: FormalPowerSeries[T]):auto =
  var ret = initFormalPowerSeries[T](min(self.len, r.len))
  for i in 0..<ret.len: ret.data[i] = self.data[i] * r.data[i]
  return ret

proc `shr`[T](self: FormalPowerSeries[T], sz:int):auto =
  if self.data.len <= sz: return initFormalPowerSeries[T](0)
  var ret = self
  if sz >= 1:
    ret.data.delete(0, sz - 1)
  return ret

proc `shl`[T](self: FormalPowerSeries[T], sz:int):auto =
  var ret = initFormalPowerSeries[T](sz)
  ret.data = ret.data & self.data
  return ret

proc diff[T](self: FormalPowerSeries[T]):auto =
  let n = self.data.len
  var ret = initFormalPowerSeries[T](max(0, n - 1))
  for i in 1..<n:
    ret.data[i - 1] = self.data[i] * T(i)
  return ret

proc integral[T](self: FormalPowerSeries[T]):auto =
  let n = self.data.len
  var ret = initFormalPowerSeries[T](n + 1)
  ret.data[0] = T(0)
  for i in 0..<n: ret.data[i + 1] = self.data[i] / T(i + 1)
  return ret

proc invFast[T](self: FormalPowerSeries[T]):auto =
  doAssert(self.data[0] != 0)
  let n = self.data.len

  var res = initFormalPowerSeries[T](1)
  res.data[0] = T(1) / self.data[0]
  let (is_set, fft, ifft) = self.getFFT()
  doAssert(is_set)
  var d = 1
  while d < n:
    var f, g = initFormalPowerSeries[T](2 * d)
    for j in 0..<min(n, 2 * d): f.data[j] = self.data[j]
    for j in 0..<d: g.data[j] = res.data[j]
    fft(f)
    fft(g)
    for j in 0..<2*d: f.data[j] *= g.data[j]
    ifft(f)
    for j in 0..<d:
      f.data[j] = T(0)
      f.data[j + d] = -f.data[j + d]
    fft(f)
    for j in 0..<2*d: f.data[j] *= g.data[j]
    ifft(f)
    for j in 0..<d: f.data[j] = res.data[j]
    res = f
    d = d shl 1
  return res.pre(n)

# F(0) must not be 0
proc inv[T](self: FormalPowerSeries[T], deg = -1):auto =
  doAssert(self.data[0] != 0)
  let n = self.data.len
  var deg = deg
  if deg == -1: deg = n
  if self.is_setFFT():
    var ret = self
    ret.data.setlen(deg)
    return ret.invFast()
  var ret = initFormalPowerSeries[T](1)
  ret.data[0] = T(1) / self.data[0]
  var i = 1
  while i < deg:
    ret = (ret + ret - ret * ret * self.pre(i shl 1)).pre(i shl 1)
    i = i shl 1
  return ret.pre(deg)

# F(0) must be 1
proc log[T](self:FormalPowerSeries[T], deg = -1):auto =
  doAssert self.data[0] == T(1)
  let n = self.data.len
  var deg = deg
  if deg == -1: deg = n
  return (self.diff() * self.inv(deg)).pre(deg - 1).integral()

proc sqrt[T](self: FormalPowerSeries[T], deg = -1):auto =
  let n = self.data.len
  var deg = deg
  if deg == -1: deg = n
  if self.data[0] == 0:
    for i in 1..<n:
      if self.data[i] != 0:
        if (i and 1) > 0: return initFormalPowerSeries[T](0)
        if deg - i div 2 <= 0: break
        var ret = (self shr i).sqrt(deg - i div 2)
        if ret.data.len == 0: return initFormalPowerSeries[T](0)
        ret = ret shl (i div 2)
        if ret.data.len < deg: ret.data.setlen(deg)
        return ret
    return initFormalPowerSeries[T](deg)

  var ret:FormalPowerSeries[T]
  if self.isSetSqrt:
    let sqr = self.getSqrt()(self.data[0])
    if sqr * sqr != self.data[0]: return initFormalPowerSeries[T](0)
    ret = initFormalPowerSeries(@[T(sqr)])
  else:
    doAssert(self.data[0] == 1)
    ret = initFormalPowerSeries(@[T(1)])

  let inv2 = T(1) / T(2);
  var i = 1
  while i < deg:
    ret = (ret + self.pre(i shl 1) * ret.inv(i shl 1)) * inv2
    i = i shl 1

  return ret.pre(deg)

proc expRec[T](self: FormalPowerSeries[T]):auto =
  doAssert self.data[0] == 0
  let n = self.data.len
  var m = 1
  while m < n: m *= 2
  var conv_coeff = initFormalPowerSeries[T](m)
  for i in 1..<n: conv_coeff.data[i] = self.data[i] * i
  return self.onlineConvolutionExp(conv_coeff).pre(n)

# F(0) must be 0
proc exp[T](self: FormalPowerSeries[T], deg = -1):auto =
  doAssert self.data[0] == 0
  let n = self.data.len
  var deg = deg
  if deg == -1: deg = n
  if self.isSetFFT:
    var ret = self
    ret.data.setlen(deg)
    return ret.expRec()
  var ret = initFormalPowerSeries(@[T(1)])
  var i = 1
  while i < deg:
    ret = (ret * (self.pre(i shl 1) + T(1) - ret.log(i shl 1))).pre(i shl 1);
    i = i shl 1
  return ret.pre(deg)

proc onlineConvolutionExp[T](self: FormalPowerSeries[T], conv_coeff:FormalPowerSeries[T]):auto =
  let n = conv_coeff.data.len
  doAssert((n and (n - 1)) == 0)
  var conv_ntt_coeff = newSeq[FormalPowerSeries[T]]()
  var i = n
  let (is_set, fft, ifft) = self.getFFT()
  doAssert(is_set)
  while (i shr 1) > 0:
    var g = conv_coeff.pre(i)
    fft(g)
    conv_ntt_coeff.add(g)
    i = i shr 1
  var conv_arg, conv_ret = initFormalPowerSeries[T](n)
  proc rec(l,r,d:int) =
    if r - l <= 16:
      for i in l..<r:
        var sum = T(0)
        for j in l..<i: sum += conv_arg.data[j] * conv_coeff.data[i - j]
        conv_ret.data[i] += sum
        conv_arg.data[i] = if i == 0: T(1) else: conv_ret.data[i] / i
    else:
      var m = (l + r) div 2
      rec(l, m, d + 1)
      var pre = initFormalPowerSeries[T](r - l)
      for i in 0..<m - l: pre.data[i] = conv_arg.data[l + i]
      fft(pre)
      for i in 0..<r - l: pre.data[i] *= conv_ntt_coeff[d].data[i]
      ifft(pre)
      for i in 0..<r - m: conv_ret.data[m + i] += pre.data[m + i - l]
      rec(m, r, d + 1);
  rec(0, n, 0)
  return conv_arg

proc pow[T](self: FormalPowerSeries[T], k:int, deg = -1):auto =
  let n = self.data.len
  var deg = deg
  if deg == -1: deg = n
  for i in 0..<n:
    if self.data[i] != T(0):
      let rev = T(1) / self.data[i]
      var ret = (((self * rev) shr i).log() * T(k)).exp() * (self.data[i]^k)
      if i * k > deg: return initFormalPowerSeries[T](deg)
      ret = (ret shl (i * k)).pre(deg)
      if ret.data.len < deg:
        ret.data.setlen(deg)
      return ret
  return self

proc eval[T](self: FormalPowerSeries[T], x:T):T =
  var
    r = T(0)
    w = T(1)
  for v in self.data:
    r += w * v
    w *= x
  return r

proc powMod[T](self: FormalPowerSeries[T], n:int, M:FormalPowerSeries[T]):auto =
  let modinv = M.rev().inv()
  proc getDiv(base:FormalPowerSeries[T]):FormalPowerSeries[T] =
    var base = base
    if base.data.len < M.data.len:
      base.data.setlen(0)
      return base
    let n = base.data.len - M.data.len + 1
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
