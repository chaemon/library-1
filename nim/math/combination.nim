#{{{ combination
import sequtils

type Combination[T] = object
  sz:int
  fact_a, rfact_a, inv_a:seq[T]

proc resize[T](self: var Combination[T], sz:int) =
  if sz < self.sz: return
  var sz = max(self.sz * 2, sz)
  self.fact_a.setlen(sz + 1)
  self.rfact_a.setlen(sz + 1)
  self.inv_a.setlen(sz + 1)
  for i in self.sz + 1..sz: self.fact_a[i] = self.fact_a[i-1] * i
  self.rfact_a[sz] = getDefault(T).init(1) / self.fact_a[sz]
  for i in countdown(sz - 1, self.sz + 1): self.rfact_a[i] = self.rfact_a[i + 1] * (i + 1)
  for i in self.sz + 1..sz: self.inv_a[i] = self.rfact_a[i] * self.fact_a[i - 1]
  self.sz = sz

proc initCombination[T](sz = 100):Combination[T] = 
  let one = getDefault(T).init(1)
  result = Combination[T](sz:0, fact_a: @[one], rfact_a: @[one], inv_a: @[one])
  result.resize(sz)

proc fact[T](self:var Combination[T], k:int):T =
  self.resize(k)
  return self.fact_a[k]
proc rfact[T](self:var Combination[T], k:int):T =
  self.resize(k)
  self.rfact_a[k]
proc inv[T](self:var Combination[T], k:int):T =
  self.resize(k)
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
