# garner {{{
proc garner[int](v:seq[tuple[a,p:int]], Mod:int):int =
  let sz = v.len
  var
    kp = newSeqWith(sz + 1, 0)
    rmult = newSeqWith(sz + 1, 1)
  var v = v
  v.add((0, Mod))
  for i in 0..<sz:
    DMint.setMod(v[i].p)
    var x = (DMint(v[i].a - kp[i]) * DMint(rmult[i]).inverse()).v
    for j in i+1..sz:
      DMint.setMod(v[j].p)
      kp[j] = (DMint(kp[j]) + DMint(rmult[j]) * x).v
      rmult[j] = (DMint(rmult[j]) * v[i].p).v
  return kp[sz]
# }}}
