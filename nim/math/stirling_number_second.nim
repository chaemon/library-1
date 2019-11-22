proc stirlingNumberSecond[T](n,k:int):T =
  var table = initCombination[T](k)
  result = T()
  for i in 0..k:
    let a = T().init(i).pow(n) * table.C(k, i)
    if((k - i) and 1)>0: result -= a
    else: result += a
  result *= table.rfact(k)
