import tables

proc prime_factor(n:int):OrderedTable[int,int] =
  var n = n
  result = initOrderedTable[int,int]()
  var i = 2
  while true:
    if i * i > n: break
    result[i] = 0
    while n mod i == 0:
      result[i] += 1
      n = n div i
    i += 1
  if n != 1: result[n] = 1
