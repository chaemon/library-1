proc bell_number[T](n,k:int):T =
  if n == 0: return T().convert(1)
  var
    k = min(k,n)
    ret = T()
    pref = newSeq[T](k + 1)
    uku = newCombination[T](k)
  pref[0] = T().convert(1);
  for i in 1..k:
    if (i and 1)>0: pref[i] = pref[i - 1] - uku.rfact(i)
    else: pref[i] = pref[i - 1] + uku.rfact(i)
  for i in 1..k: ret += T().convert(i).pow(n) * uku.rfact(i) * pref[k - i]
  return ret
