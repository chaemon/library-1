#{{{ suffix Array
type SuffixArray = object
  s:string
  SA:seq[int]


proc lt_substr(self: SuffixArray, t:string, si = 0, ti = 0):bool =
  let
    sn = self.s.len
    tn = t.len
  var
    si = si
    ti = ti
  while si < sn and ti < tn:
    if self.s[si] < t[ti]: return true
    if self.s[si] > t[ti]: return false
    si += 1;ti += 1
  return si >= sn and ti < tn

proc initSuffixArray(s:string):SuffixArray = 
  var
    n = s.len
  result = SuffixArray()
  result.s = s
  result.SA = newSeq[int](n)
  for i in 0..<n:
    result.SA[i] = i
  proc cmp_sa(a,b:int):int =
    return
      if s[a] == s[b]: cmp[int](b,a)
      else: cmp[char](s[a],s[b])
  result.SA.sort(cmp_sa)
  var
    classes = newSeq[int](n)
    c = map(s,proc (x:char):int = ord(x))
    cnt:seq[int]
    len = 1
  while len < n:
    for i in 0..<n:
      if i > 0 and c[result.SA[i - 1]] == c[result.SA[i]] and result.SA[i - 1] + len < s.len and c[result.SA[i - 1] + len div 2] == c[result.SA[i] + len div 2]:
        classes[result.SA[i]] = classes[result.SA[i - 1]];
      else:
        classes[result.SA[i]] = i;
    cnt = newSeq[int](n)
    for i in 0..<n:
      c[i] = result.SA[i]
      cnt[i] = i
    for i in 0..<n:
      var s1 = c[i] - len
      if s1 >= 0: result.SA[cnt[classes[s1]]] = s1;cnt[classes[s1]] += 1
    classes.swap(c);
    len *= 2

proc `[]`(self:SuffixArray, k:int):int =
  return self.SA[k]

proc size(self:SuffixArray):int =
  return self.s.len

proc lowerBound(self:SuffixArray, t:string):int =
  var
    low = -1
    high = self.size
  while high - low > 1:
    var mid = (low + high) div 2
    if self.lt_substr(t, self.SA[mid]): low = mid
    else: high = mid
  return high

proc lowerUpperBound(self:SuffixArray, t:string):(int,int) =
  var
    idx = self.lowerBound(t)
    low = idx - 1
    high = self.size
    t = t
  t[^1] = chr(ord(t[^1]) + 1)
  while high - low > 1:
    var mid = (low + high) div 2
    if self.lt_substr(t, self.SA[mid]): low = mid
    else: high = mid
  t[^1] = chr(ord(t[^1]) - 1)
  return (idx, high)

proc output(self:SuffixArray):void =
  for i in 0..<self.s.len:
    echo i, ": ", self.s.substr[self.SA[i]..<self.s.len]
#}}}
