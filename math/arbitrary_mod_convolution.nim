#{{{ ArbitraryModConvolution
type ArbitraryModConvolution[ModInt] = object

proc init[ModInt](t:typedesc[ArbitraryModConvolution[ModInt]]):auto =
  ArbitraryModConvolution[ModInt]()

proc multiply[ModInt](self:var ArbitraryModConvolution[ModInt], a,b:seq[ModInt], need = -1):seq[ModInt] =
  var need = need
  if need == -1: need = a.len + b.len - 1
  var nbase = 0
  while (1 shl nbase) < need: nbase.inc
  fft_t.ensureBase(nbase)
  let sz = 1 shl nbase
  var fa = initSeqC(sz)
  for i in 0..<a.len: fa[i] = initC(a[i].v and ((1 shl 15) - 1), a[i].v shr 15)
  fft_t.fft(fa, sz)
  var fb = initSeqC(sz)
  if a == b:
    fb = fa
  else:
    for i in 0..<b.len:
      fb[i] = initC(b[i].v and ((1 shl 15) - 1), b[i].v shr 15)
    fft_t.fft(fb, sz)
  let ratio = 1.Real / (sz.Real * 4.Real)
  let
    r2 = initC(0, -1)
    r3 = initC(ratio, 0)
    r4 = initC(0, -ratio)
    r5 = initC(0, 1)
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
  fft_t.fft(fa, sz)
  fft_t.fft(fb, sz)
  result = newSeq[ModInt](need)
  for i in 0..<need:
    var
      aa = llround(fa[i].x)
      bb = llround(fb[i].x)
      cc = llround(fa[i].y)
    aa = ModInt(aa).v; bb = ModInt(bb).v; cc = ModInt(cc).v
    result[i] = ModInt(aa + (bb shl 15) + (cc shl 30))

proc fft[ModInt](self: var ArbitraryModConvolution[ModInt], a:seq[ModInt]):SeqC =
  result = initSeqC(a.len)
  result.real = a.mapIt(Real(it.v))
  fft_t.fft(result, a.len)
proc ifft[ModInt](self: var ArbitraryModConvolution[ModInt], a:SeqC):seq[ModInt] =
  let n = a.real.len
  var a = a
  fft_t.ifft(a, n)
  return a.real.mapIt(ModInt(llround(it)))
proc fftType[ModInt](self: typedesc[ArbitraryModConvolution[ModInt]]):auto = typedesc[SeqC]
#}}}

type BaseFFT[T] = ArbitraryModConvolution[T]
