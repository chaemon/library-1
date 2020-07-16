# ArbitraryModConvolution by NumberTheoricTransform {{{
declareDMint(DMintLocal)
type ArbitraryModConvolutionNTT[ModInt] = object
  ps:array[3, (int,int)]
  ntt:array[3, NumberTheoreticTransform[DMintLocal]]

#  remainder, primitive_root
#  (924844033, 5)
#  (998244353, 3)
#  (1012924417, 5)
#  (167772161, 3)
#  (469762049, 3)
#  (1224736769, 3)

proc init[ModInt](self:typedesc[ArbitraryModConvolutionNTT[ModInt]]):ArbitraryModConvolutionNTT[ModInt] =
  result = ArbitraryModConvolutionNTT[ModInt]()
  result.ps= [(924844033, 5), (998244353, 3), (1012924417, 5)]
  for i,(p,r) in result.ps:
    DMintLocal.setMod(p)
    result.ntt[i] = initNumberTheoreticTransform[DMintLocal](r)

proc fft[ModInt](self: var ArbitraryModConvolutionNTT[ModInt], a:seq[ModInt]):array[3, seq[DMintLocal]] =
  for i,(p,r) in self.ps:
    DMintLocal.setMod(p)
    result[i] = self.ntt[i].fft(a.mapIt(DMintLocal(it.v)))

proc dot[ModInt](self: ArbitraryModConvolutionNTT[ModInt], a, b:array[3, seq[DMintLocal]]):array[3, seq[DMintLocal]] =
  for i,(p,r) in self.ps:
    DMintLocal.setMod(p)
    result[i] = self.ntt[i].dot(a[i],b[i])

proc ifft[ModInt](self: var ArbitraryModConvolutionNTT[ModInt], a:array[3, seq[DMintLocal]]):seq[ModInt] =
  let
    n = a[0].len
    p0 = ModInt.getMod()
  var a = a
  for j,(p, r) in self.ps:
    DMintLocal.setMod(p)
    a[j] = self.ntt[j].ifft(a[j])
  result = newSeq[ModInt]()
  for i in 0..<n:
    var x = newSeq[(int,int)]()
    for j,(p, r) in self.ps:
      x.add((a[j][i].v.int, p))
    result.add(garner(x, p0))

proc ensureBase[ModInt](self: var ArbitraryModConvolutionNTT[ModInt], nbase:int) =
  for i,(p,r) in self.ps:
    DMintLocal.setMod(p)
    self.ntt[i].ensureBase(nbase)

proc multiply[ModInt](self:var ArbitraryModConvolutionNTT[ModInt], a,b:seq[ModInt]):seq[ModInt] =
  let need = a.len + b.len - 1
  var nbase = 1
  while (1 shl nbase) < need: nbase += 1
  self.ensureBase(nbase)
  let sz = 1 shl nbase
  var (a, b) = (a, b)
  a.setLen(sz)
  b.setLen(sz)

  result = self.ifft(self.dot(self.fft(a), self.fft(b)))
  result.setLen(need)
# }}}
