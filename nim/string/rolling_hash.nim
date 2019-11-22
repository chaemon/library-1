import sequtils

const MOD = 1000000007'u

type RollingHash = object
  hashed, power: seq[uint]

proc mul(a,b:uint):uint =
  return (a * b) mod MOD
#  let
#    x = a * b
#    xh = (x shr 32'u)
#    xl = x
#  var d, m:uint
#  asm """ "divl %4; \n\t" : "=a" (d), "=d" (m) : "d" (xh), "a" (xl), "r" (MOD));" """
#  return m

proc initRollingHash(s:string, base = 10007'u):RollingHash =
  var
    sz = s.len
    hashed = newSeqWith(sz + 1, 0'u)
    power = newSeqWith(sz + 1, 0'u)
  power[0] = 1'u
  for i in 0..<sz:
    power[i + 1] = mul(power[i], base);
    hashed[i + 1] = mul(hashed[i], base) + uint(s[i].ord)
    if hashed[i + 1] >= MOD: hashed[i + 1] -= MOD
  return RollingHash(hashed: hashed, power: power)

proc get(self: RollingHash; l, r:int):uint =
  result = self.hashed[r] + MOD - mul(self.hashed[l], self.power[r - l])
  if result >= MOD: result -= MOD

proc connect(self: RollingHash; h1, h2:uint, h2len:int):uint =
  result = mul(h1, self.power[h2len]) + h2
  if result >= MOD: result -= MOD

proc LCP(self, b:RollingHash; l1, r1, l2, r2:int):int =
  var
    len = min(r1 - l1, r2 - l2)
    low = -1
    high = len + 1
  while high - low > 1:
    let mid = (low + high) div 2
    if self.get(l1, l1 + mid) == b.get(l2, l2 + mid): low = mid
    else: high = mid
  return low
