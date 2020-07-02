# ArbitraryModConvolutionLong {{{
type ArbitraryModConvolutionLong = object
  discard

proc llround(n:float): int{.importc: "llround", nodecl.}

proc multiply[ModInt](self: ArbitraryModConvolutionLong, a, b:seq[ModInt], need = -1):seq[ModInt] =
  if need == -1: need = a.len + b.len - 1
  var nbase = 0
  while (1 shl nbase) < need: nbase.inc
  var fft = initFastFourierTransform()
  fft.ensure_base(nbase)
  let sz = 1 shl nbase
  var fa = newSeq[C](sz)
  for i in 0..<a.len: fa[i] = initC(a[i].v and ((1 shl 19) - 1), a[i].v shr 19)
  fft.fft(fa, sz)
  var fb = newSeq[C](sz)
  if a == b:
    fb = fa
  else:
    for i in 0..<b.len:
      fb[i] = initC(b[i].v and ((1 shl 19) - 1), b[i].v shr 19)
    fft.fft(fb, sz)
  let ratio = 0.25 / sz.float
  let
    r2 = initC(0, -1)
    r3 = initC(ratio, 0)
    r4 = initC(0, -ratio)
    r5 = initC(0, 1)
  for i in 0..(sz shr 1):
    let
      j = (sz - i) and (sz - 1)
      a1 = initC(fa[i] + fa[j].conj())
      a2 = initC(fa[i] - fa[j].conj()) * r2
      b1 = initC(fb[i] + fb[j].conj()) * r3
      b2 = initC(fb[i] - fb[j].conj()) * r4
    if i != j:
      let
        c1 = initC(fa[j] + fa[i].conj())
        c2 = initC(fa[j] - fa[i].conj()) * r2
        d1 = initC(fb[j] + fb[i].conj()) * r3
        d2 = initC(fb[j] - fb[i].conj()) * r4
      fa[i] = c1 * d1 + c2 * d2 * r5
      fb[i] = c1 * d2 + c2 * d1
    fa[j] = a1 * b1 + a2 * b2 * r5
    fb[j] = a1 * b2 + a2 * b1
  fft(fa, sz)
  fft(fb, sz)
  result = newSeq[ModInt](need)
  let
    mul1 = ModInt(2)^19
    mul2 = ModInt(2)^38
  for i in 0..<need:
    var
      aa = llround(fa[i].x)
      bb = llround(fb[i].x)
      cc = llround(fa[i].y)
    aa = ModInt(aa).v; bb = ModInt(bb).v; cc = ModInt(cc).v
    result[i] = (mul1 * bb) + (mul2 * cc) + aa
# }}}
