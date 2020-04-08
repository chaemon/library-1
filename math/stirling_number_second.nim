proc stirlingNumberSecond[T](n,k:int):T =
  result = T()
  for i in 0..k:
    let a = T().init(i)^n * T.C(k, i)
    if((k - i) and 1)>0: result -= a
    else: result += a
  result *= T.rfact(k)
