proc bell_number[T](n,k:int):T =
  if n == 0: return T(1)
  var
    k = min(k,n)
    ret = T(0)
    pref = newSeq[T](k + 1)
  pref[0] = T(1);
  for i in 1..k:
    if (i and 1)>0: pref[i] = pref[i - 1] - T.rfact(i)
    else: pref[i] = pref[i - 1] + T.rfact(i)
  for i in 1..k: ret += T(i)^n * T.rfact(i) * pref[k - i]
  return ret
