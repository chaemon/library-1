# {{{ FormalPowerSeries Seq
proc bernoulli[T](N:int):FormalPowerSeries[T] =
  result = initFormalPowerSeries[T](N+1)
  result[0] = T(1)
  for i in 1..N: result[i] = result[i-1] / T(i+1)
  result = result.inv()
  var tmp = T(1)
  for i in 1..N: tmp *= T(i);result[i] *= tmp

proc partition[T](N:int):FormalPowerSeries[T] =
  result = initFormalPowerSeries[T](N+1)
  result[0] = T(1)
  for k in 1..N:
    if k * (3 * k + 1) div 2 <= N: result[k * (3 * k + 1) div 2] += ( if k mod 2 == 1: -1 else: 1)
    if k * (3 * k - 1) div 2 <= N: result[k * (3 * k - 1) div 2] += ( if k mod 2 == 1: -1 else: 1)
  result = result.inv()

proc bell[T](N:int):FormalPowerSeries[T] =
  result = initFormalPowerSeries[T](N+1)
  var poly = initFormalPowerSeries[T](N+1)
  poly[1] = T(1)
  poly = poly.exp()
  poly[0] -= T(1)
  poly = poly.exp()
  var mul = T(1)
  for i in 0..N:
    result[i] = poly[i] * mul
    mul *= T(i+1)

proc stirlingFirst[T](N:int):FormalPowerSeries[T] =
  result = initFormalPowerSeries[T](N + 1)
  if N == 0:
    result[0] = T(1)
    return
  let M = N div 2
  var
    A = stirlingFirst[T](M)
    B:FormalPowerSeries[T]
    C = initFormalPowerSeries[T](N - M + 1)

  if N mod 2 == 0:
    B = A
  else:
    B.setlen(M + 2)
    B[M + 1] = T(1)
    for i in 1..M: B[i] = A[i - 1] + A[i] * M

  var tmp = T(1)
  for i in 0..N-M:
    C[N - M - i] = T(M)^i / tmp
    B[i] *= tmp
    tmp *= T(i + 1)
  C *= B
  tmp = T(1)
  for i in 0..N-M:
    B[i] = C[N - M + i] / tmp
    tmp *= T(i + 1)
  return A * B

proc stirlingSecond[T](N:int):FormalPowerSeries[T] =
  var
    A, B = initFormalPowerSeries[T](N + 1)
    tmp = T(1)
  for i in 0..N:
    let rev = T(1) / tmp
    A[i] = T(i)^N * rev
    B[i] = T(1) * rev
    if i mod 2 == 1: B[i] *= -1
    tmp *= i + 1
  return (A * B).pre(N + 1)

proc stirlingSecondKthColumn[T](N, K:int):FormalPowerSeries[T] =
  var poly, ret = initFormalPowerSeries[T](N + 1)
  poly[1] = T(1)
  poly = poly.exp()
  poly[0] -= 1
  poly = poly.pow(K)
  var
    rev = T(1)
    mul = T(1)
  for i in 2..K: rev *= i
  rev = T(1) / rev
  poly *= rev
  for i in 0..N:
    ret[i] = poly[i] * mul
    mul *= i + 1
  return ret

proc eulerian[T](N:int):FormalPowerSeries[T] =
  var fact, rfact = newSeq[T](N + 2)
  fact[0] = 1
  rfact[N + 1] = 1
  for i in 1..N+1: fact[i] = fact[i - 1] * i
  rfact[N + 1] /= fact[N + 1]
  for i in countdown(N, 0): rfact[i] = rfact[i + 1] * (i + 1)

  var A, B = initFormalPowerSeries[T](N + 1)
  for i in 0..N:
    A[i] = fact[N + 1] * rfact[i] * rfact[N + 1 - i]
    if i mod 2 == 1: A[i] *= -1
    B[i] = T(i + 1).pow(N)
  return (A * B).pre(N + 1)
# }}}
