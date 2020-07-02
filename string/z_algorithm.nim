proc z_algorithm(s:string):seq[int] =
  var prefix = newSeq[int](s.len)
  var j = 0
  for i in 1..<s.len:
    if i + prefix[i - j] < j + prefix[j]:
      prefix[i] = prefix[i - j]
    else:
      var k = max(0, j + prefix[j] - i)
      while i + k < s.len and s[k] == s[i + k]: k.inc
      prefix[i] = k
      j = i
  prefix[0] = s.len
  return prefix
