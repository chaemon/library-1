type NumberTheoreticTransformArbitraryMod[ModInt] = object
  discard


proc initNumberTheoreticTransformArbitraryMod[ModInt]():NumberTheoreticTransformArbitraryMod[ModInt] =
  NumberTheoreticTransformArbitraryMod[ModInt]()

proc multiply[ModInt](self:NumberTheoreticTransformArbitraryMod[ModInt], a,b:seq[int]):seq[int] =
#  remainder, primitive_root
#  (924844033, 5)
#  (998244353, 3)
#  (1012924417, 5)
#  (167772161, 3)
#  (469762049, 3)
#  (1224736769, 3)

  let ps = [(924844033, 5), (998244353, 3), (1012924417, 5)]
  var v = newSeq[seq[int]]()

  for (p, r) in ps:
    DMint.setMod(p)
    var ntt = initNumberTheoreticTransform[DMint](r)
    let c = ntt.multiply(a.mapIt(DMint(it)), b.mapIt(DMint(it)))
    v.add(c.mapIt(it.v.int))
  result = newSeq[int]()

  for i in 0..<a.len + b.len - 1:
    var
      x = newSeq[(int,int)]()
    for j,(p, r) in ps:
      x.add((v[j][i], p))
    result.add(garner(x, ModInt.getMod()))
