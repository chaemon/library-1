# combination {{{
import sequtils

#proc `/`(a, b:int):int = a div b

type IntC = concept x
  x + x
  x - x
  x * x
  x / x

proc fact(T:typedesc[IntC], k:int):T =
  var fact_a{.global.} = newSeq[T]()
  if k >= fact_a.len:
    if fact_a.len == 0: fact_a = @[T(1)]
    let sz_old = fact_a.len - 1
    let sz = max(sz_old * 2, k)
    fact_a.setlen(sz + 1)
    for i in sz_old + 1..sz: fact_a[i] = fact_a[i-1] * T(i)
  return fact_a[k]
proc rfact(T:typedesc[IntC], k:int):T =
  var rfact_a{.global.} = newSeq[T]()
  if k >= rfact_a.len:
    if rfact_a.len == 0: rfact_a = @[T(1)]
    let sz_old = rfact_a.len - 1
    let sz = max(sz_old * 2, k)
    rfact_a.setlen(sz + 1)
    rfact_a[sz] = T(1) / T.fact(sz)
    for i in countdown(sz - 1, sz_old + 1): rfact_a[i] = rfact_a[i + 1] * T(i + 1)
  return rfact_a[k]

proc inv(T:typedesc[IntC], k:int):T =
  return T.fact_a(k - 1) * T.rfact(k)

proc P(T:typedesc[IntC], n,r:int):T =
  if r < 0 or n < r: return T(0)
  return T.fact(n) * T.rfact(n - r)
proc C(T:typedesc[IntC], p,q:int):T =
  if q < 0 or p < q: return T(0)
  return T.fact(p) * T.rfact(q) * T.rfact(p - q)
proc H(T: typedesc[IntC], n,r:int):T =
  if n < 0 or r < 0: return T(0)
  return if r == 0: T(1) else: T.C(n + r - 1, r)
# }}}
