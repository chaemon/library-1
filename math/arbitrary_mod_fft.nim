const ArbitraryMod = true
#{{{ ArbitraryModFFT
type ArbitraryModFFT[ModInt] = object

proc init[ModInt](t:typedesc[ArbitraryModFFT[ModInt]]):auto =
  ArbitraryModFFT[ModInt]()

proc ceil_log2(n:int):int =
  result = 0
  while (1 shl result) < n: result.inc

proc fft[ModInt](self: var ArbitraryModFFT[ModInt], a:seq[ModInt]):SeqComplex =
  doAssert((a.len and (a.len - 1)) == 0)
  let l = ceil_log2(a.len)
  fft_t.ensureBase(l)
  result = initSeqComplex(a.len)
  for i in 0..<a.len: result[i] = initComplex(a[i].v and ((1 shl 15) - 1), a[i].v shr 15)
  fft_t.fft(result, a.len)

proc dot[ModInt](self: ArbitraryModFFT[ModInt], fa: SeqComplex, fb:SeqComplex):(SeqComplex, SeqComplex) =
  let sz = fa.real.len
  var (fa, fb) = (fa, fb)
  let ratio = Real(1) / (Real(sz) * Real(4))
  let
    r2 = initComplex(0, -1)
    r3 = initComplex(ratio, 0)
    r4 = initComplex(0, -ratio)
    r5 = initComplex(0, 1)
  for i in 0..(sz shr 1):
    let
      j = (sz - i) and (sz - 1)
      a1 = (fa[i] + fa[j].conj())
      a2 = (fa[i] - fa[j].conj()) * r2
      b1 = (fb[i] + fb[j].conj()) * r3
      b2 = (fb[i] - fb[j].conj()) * r4
    if i != j:
      let
        c1 = (fa[j] + fa[i].conj())
        c2 = (fa[j] - fa[i].conj()) * r2
        d1 = (fb[j] + fb[i].conj()) * r3
        d2 = (fb[j] - fb[i].conj()) * r4
      fa[i] = c1 * d1 + c2 * d2 * r5
      fb[i] = c1 * d2 + c2 * d1
    fa[j] = a1 * b1 + a2 * b2 * r5
    fb[j] = a1 * b2 + a2 * b1
  return (fa, fb)

proc ifft[ModInt](self: var ArbitraryModFFT[ModInt], p:(SeqComplex, SeqComplex), need = -1):seq[ModInt] =
  var
    (fa, fb) = p
  let
    sz = fa.real.len
  fft_t.fft(fa, sz)
  fft_t.fft(fb, sz)
  let need = if need == -1: fa.real.len else: need
  result = newSeq[ModInt](need)
  for i in 0..<need:
    var
      aa = llround(fa[i].x)
      bb = llround(fb[i].x)
      cc = llround(fa[i].y)
    aa = ModInt(aa).v; bb = ModInt(bb).v; cc = ModInt(cc).v
    result[i] = ModInt(aa + (bb shl 15) + (cc shl 30))

proc multiply[ModInt](self:var ArbitraryModFFT[ModInt], a,b:seq[ModInt], need = -1):seq[ModInt] =
  var need = need
  if need == -1: need = a.len + b.len - 1
  var nbase = ceil_log2(need)
  fft_t.ensureBase(nbase)
  let sz = 1 shl nbase
  var (a, b) = (a, b)
  a.setlen(sz)
  b.setlen(sz)
  var
    fa1 = self.fft(a)
    fb1 = if a == b: fa1 else: self.fft(b)
  (fa1, fb1) = self.dot(fa1, fb1)
  return self.ifft((fa1, fb1), need)
#}}}
