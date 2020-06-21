import sugar

# merge {{{
proc merge[S,T](a, b:seq[(S,T)], merger:(T,T)->T = nil):seq[(S,T)] =
  var
    i = 0
    j = 0
  result = newSeq[(int,int)]()
  while true:
    if i == a.len:
      if j == b.len:
        break
      else:
        result.add(b[j])
        j.inc
    elif j == b.len:
      result.add(a[i])
      i.inc
    else:
      if a[i][0] < b[j][0]:
        result.add(a[i])
        i.inc
      elif a[i][0] > b[j][0]:
        result.add(b[j])
        j.inc
      else:
        if merger != nil:
          result.add((a[i][0], merger(a[i][1], b[j][1])))
        else:
          result.add(a[i])
          result.add(b[j])
        i.inc;j.inc
# }}}
