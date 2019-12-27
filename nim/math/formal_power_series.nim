import future

type
  FormalPowerSeries[T] = object
    data: seq[T]

proc initFormalPowerSeries[T](n:int):FormalPowerSeries[T] = FormalPowerSeries[T](data:newSeq[T](n))
proc initFormalPowerSeries[T](data: seq[T]):FormalPowerSeries[T] = FormalPowerSeries[T](data:data)

proc `$`[T](self:FormalPowerSeries[T]):string = self.data.map(`$`).join(" ")

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
proc setMult[T](self:FormalPowerSeries[T], f:MULT[T]):MULT[T]{.discardable.} =
  return self.multSub(true, f)
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
proc setFFT[T](self:FormalPowerSeries[T], f, g: FFT[T]) {.discardable.} = self.FFTSub(true, f, g)
proc isSetFFT[T](self:FormalPowerSeries[T]):bool = return self.FFTSub(false, nil, nil)[0]
proc getFFT[T](self:FormalPowerSeries[T]):FFT[T] {.discardable.} = return self.FFTSub(false, nil, nil)[1]
proc getIFFT[T](self:FormalPowerSeries[T]):FFT[T] {.discardable.} = return self.FFTSub(false, nil, nil)[2]

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

#{{{ operators
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

proc `mod=`[T](self: var FormalPowerSeries[T], r:FormalPowerSeries[T]):FormalPowerSeries[T] = self -= self / r * r

proc `-`[T](self: FormalPowerSeries[T]):FormalPowerSeries[T] =
  var ret = self
  for i in 0..<self.data.len: ret.data[i] = -self.data[i]
  return ret
proc `/=`[T](self: var FormalPowerSeries[T], v:T) =
  for t in self.data.mitems: t /= v
#}}}

proc rev[T](self: FormalPowerSeries[T], deg = -1):FormalPowerSeries[T] =
  var ret = self
  if deg != -1: ret.data.setlen(deg)
  ret.data.reverse
  return ret

proc pre[T](self: FormalPowerSeries[T], sz:int):FormalPowerSeries[T] =
  result = self
  result.data.setlen(min(self.data.len, sz))

proc `div=`[T](self: var FormalPowerSeries[T], r: FormalPowerSeries[T]):FormalPowerSeries[T] =
  if self.data.len < r.data.len:
    self.setlen(0)
  else:
    let n = self.len - r.len + 1
    self = (self.rev().pre(n) * r.rev().inv(n)).pre(n).rev(n);

proc dot[T](self:FormalPowerSeries[T], r: FormalPowerSeries[T]):FormalPowerSeries[T] =
  var ret = initFormalPowerSeries[T](min(self.len, r.len))
  for i in 0..<ret.len: ret.data[i] = self.data[i] * r.data[i]
  return ret

proc `shr`[T](self: FormalPowerSeries[T], sz:int):FormalPowerSeries[T] =
  if self.data.len <= sz: return initFormalPowerSeries[T](0)
  var ret = self
  ret.data.delete(0, sz - 1)
#  ret.erase(ret.begin(), ret.begin() + sz);
  return ret

proc `shl`[T](self: FormalPowerSeries[T], sz:int):FormalPowerSeries[T] =
  var ret = initFormalPowerSeries[T](sz)
  ret.data = ret.data & self.data
  return ret

proc diff[T](self: FormalPowerSeries[T]):FormalPowerSeries[T] =
  let n = self.data.len
  var ret = initFormalPowerSeries[T](max(0, n - 1))
  for i in 1..<n:
    ret.data[i - 1] = self.data[i] * T().init(i)
  return ret

proc integral[T](self: FormalPowerSeries[T]):FormalPowerSeries[T] =
  let n = self.data.len
  var ret = initFormalPowerSeries[T](n + 1)
  ret.data[0] = T().init(0)
  for i in 0..<n: ret.data[i + 1] = self.data[i] / T().init(i + 1)
  return ret

proc invFast[T](self: FormalPowerSeries[T]):FormalPowerSeries[T] =
  assert(self.data[0] != 0)
  let n = self.data.len

  var res = initFormalPowerSeries[T](1)
  res.data[0] = T().init(1) / self.data[0]

  var d = 1
  while d < n:
    var f, g = initFormalPowerSeries[T](2 * d)
    for j in 0..<min(n, 2 * d): f.data[j] = self.data[j]
    for j in 0..<d: g.data[j] = res.data[j]
    (self.getFFT)(f)
    (self.getFFT)(g)
    for j in 0..<2*d: f.data[j] *= g.data[j]
    (self.getIFFT)(f)
    for j in 0..<d:
      f.data[j] = T().init(0)
      f.data[j + d] = -f.data[j + d]
    (self.getFFT)(f)
    for j in 0..<2*d: f.data[j] *= g.data[j]
    (self.getIFFT)(f)
    for j in 0..<d: f.data[j] = res.data[j]
    res = f
    d = d shl 1
  return res.pre(n);

# F(0) must not be 0
proc inv[T](self: FormalPowerSeries[T], deg = -1):FormalPowerSeries[T] =
  assert(self.data[0] != 0)
  let n = self.data.len
  var deg = deg
  if deg == -1: deg = n
  if self.is_setFFT():
    var ret = self
    ret.data.setlen(deg)
    return ret.invFast()
  var ret = initFormalPowerSeries[T](1)
  ret.data[0] = T().init(1) / self.data[0]
  var i = 1
  while i < deg:
    ret = (ret + ret - ret * ret * self.pre(i shl 1)).pre(i shl 1)
    i = i shl 1
  return ret.pre(deg)

# F(0) must be 1
proc log[T](self:FormalPowerSeries[T], deg = -1):FormalPowerSeries[T] =
  assert self.data[0] == 1
  let n = self.data.len
  var deg = deg
  if deg == -1: deg = n
  return (self.diff() * self.inv(deg)).pre(deg - 1).integral()

proc sqrt[T](self: FormalPowerSeries[T], deg = -1):FormalPowerSeries[T] =
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
    let sqr = self.get_sqrt()(self.data[0])
    if sqr * sqr != self.data[0]: return initFormalPowerSeries[T](0)
    ret = initFormalPowerSeries(@[T().init(sqr)])
  else:
    assert(self.data[0] == 1)
    ret = initFormalPowerSeries(@[T().init(1)])

  let inv2 = T().init(1) / T().init(2);
  var i = 1
  while i < deg:
    ret = (ret + self.pre(i shl 1) * ret.inv(i shl 1)) * inv2
    i = i shl 1

  return ret.pre(deg)

proc expRec[T](self: FormalPowerSeries[T]):FormalPowerSeries[T] =
  assert self.data[0] == 0
  let n = self.data.len
  var m = 1
  while m < n: m *= 2
  var conv_coeff = initFormalPowerSeries[T](m)
  for i in 1..<n: conv_coeff.data[i] = self.data[i] * i
  return self.onlineConvolutionExp(conv_coeff).pre(n)

# F(0) must be 0
proc exp[T](self: FormalPowerSeries[T], deg = -1):FormalPowerSeries[T] =
  assert self.data[0] == 0
  let n = self.data.len
  var deg = deg
  if deg == -1: deg = n
  if self.isSetFFT:
    var ret = self
    ret.data.setlen(deg)
    return ret.expRec()
  var ret = initFormalPowerSeries(@[T().init(1)])
  var i = 1
  while i < deg:
    ret = (ret * (self.pre(i shl 1) + T().init(1) - ret.log(i shl 1))).pre(i shl 1);
    i = i shl 1
  return ret.pre(deg);

proc onlineConvolutionExp[T](self: FormalPowerSeries[T], conv_coeff:FormalPowerSeries[T]):FormalPowerSeries[T] =
  let n = conv_coeff.data.len
  assert((n and (n - 1)) == 0)
  var conv_ntt_coeff = newSeq[FormalPowerSeries[T]]()
  var i = n
  while (i shr 1) > 0:
    var g = conv_coeff.pre(i)
    self.get_fft()(g)
    conv_ntt_coeff.add(g)
    i = i shr 1
  var conv_arg, conv_ret = initFormalPowerSeries[T](n)
  proc rec(l,r,d:int) =
    if r - l <= 16:
      for i in l..<r:
        var sum = T().init(0)
        for j in l..<i: sum += conv_arg.data[j] * conv_coeff.data[i - j]
        conv_ret.data[i] += sum
        conv_arg.data[i] = if i == 0: T().init(1) else: conv_ret.data[i] / i
    else:
      var m = (l + r) div 2
      rec(l, m, d + 1)
      var pre = initFormalPowerSeries[T](r - l)
      for i in 0..<m - l: pre.data[i] = conv_arg.data[l + i]
      self.getFFT()(pre)
      for i in 0..<r - l: pre.data[i] *= conv_ntt_coeff[d].data[i]
      self.getIFFT()(pre)
      for i in 0..<r - m: conv_ret.data[m + i] += pre.data[m + i - l]
      rec(m, r, d + 1);
  rec(0, n, 0)
  return conv_arg


#P pow(int64_t k, int deg = -1) const {
#  const int n = (int) self.len;
#  if(deg == -1) deg = n;
#  for(int i = 0; i < n; i++) {
#    if((*self)[i] != T(0)) {
#      T rev = T(1) / (*self)[i];
#      P ret = (((*self * rev) >> i).log() * k).exp() * ((*self)[i].pow(k));
#      if(i * k > deg) return P(deg, T(0));
#      ret = (ret << (i * k)).pre(deg);
#      if(ret.len < deg) ret.setlen(deg, T(0));
#      return ret;
#    }
#  }
#  return *self;
#}
#
#T eval(T x) const {
#  T r = 0, w = 1;
#  for(auto &v : *self) {
#    r += w * v;
#    w *= x;
#  }
#  return r;
#}
#
#P pow_mod(int64_t n, P mod) const {
#  P modinv = mod.rev().inv();
#  auto get_div = [&](P base) {
#    if(base.len < mod.len) {
#      base.clear();
#      return base;
#    }
#    int n = base.len - mod.len + 1;
#    return (base.rev().pre(n) * modinv.pre(n)).pre(n).rev(n);
#  };
#  P x(*self), ret{1};
#  while(n > 0) {
#    if(n & 1) {
#      ret *= x;
#      ret -= get_div(ret) * mod;
#    }
#    x *= x;
#    x -= get_div(x) * mod;
#    n >>= 1;
#  }
#  return ret;
#}


proc `+`[T](self:FormalPowerSeries[T];r:FormalPowerSeries[T]):FormalPowerSeries[T] =  result = self;result += r
proc `+`[T](self:FormalPowerSeries[T];v:T   ):FormalPowerSeries[T] =  result = self;result += v
proc `-`[T](self:FormalPowerSeries[T];r:FormalPowerSeries[T]):FormalPowerSeries[T] =  result = self;result -= r
proc `-`[T](self:FormalPowerSeries[T];v:T   ):FormalPowerSeries[T] =  result = self;result -= v
proc `*`[T](self:FormalPowerSeries[T];r:FormalPowerSeries[T]):FormalPowerSeries[T] =  result = self;result *= r
proc `*`[T](self:FormalPowerSeries[T];v:T   ):FormalPowerSeries[T] =  result = self;result *= v
proc `div`[T](self:FormalPowerSeries[T];r:FormalPowerSeries[T]):FormalPowerSeries[T] =  result = self;result `div=` (r)
proc `mod`[T](self:FormalPowerSeries[T];r:FormalPowerSeries[T]):FormalPowerSeries[T] =  result = self;result `mod=` (r)

