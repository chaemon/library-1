#{{{ combination
import sequtils

type Combination[T] = object
  sz:int
  fact_a, rfact_a, inv_a:seq[T]

proc initCombination[T](sz = 100):Combination[T] = 
  var
    fact_a = newSeqWith(sz + 1, getDefault(T))
    rfact_a = newSeqWith(sz + 1, getDefault(T))
    inv_a = newSeqWith(sz + 1, getDefault(T))
  fact_a[0] = getDefault(T).init(1)
  rfact_a[sz] = getDefault(T).init(1)
  inv_a[0] = getDefault(T).init(1)
  for i in 1..sz:fact_a[i] = fact_a[i-1] * i
  rfact_a[sz] /= fact_a[sz]
  for i in countdown(sz - 1, 0): rfact_a[i] = rfact_a[i + 1] * (i + 1)
  for i in 1..sz: inv_a[i] = rfact_a[i] * fact_a[i - 1]
  return Combination[T](sz:sz, fact_a:fact_a, rfact_a:rfact_a,inv_a:inv_a)

proc fact[T](self:var Combination[T], k:int):T =
  while self.sz < k:self = initCombination[T](self.sz*2)
  return self.fact_a[k]
proc rfact[T](self:var Combination[T], k:int):T =
  while self.sz < k:self = initCombination[T](self.sz*2)
  self.rfact_a[k]
proc inv[T](self:var Combination[T], k:int):T =
  while self.sz < k:self = initCombination[T](self.sz*2)
  self.inv_a[k]

proc P[T](self:var Combination[T], n,r:int):T =
  if r < 0 or n < r: return T()
  return self.fact(n) * self.rfact(n - r)

proc C[T](self:var Combination[T], p,q:int):T =
  if q < 0 or p < q: return T()
  return self.fact(p) * self.rfact(q) * self.rfact(p - q)

proc H[T](self:var Combination[T], n,r:int):T =
  if n < 0 or r < 0: return T()
  return if r == 0: T().init(1) else: self.C(n + r - 1, r)
#}}}
