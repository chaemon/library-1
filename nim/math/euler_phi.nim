proc eulerPhi(n:int):int =
  var
    n = n
    i = 2
  result = n
  while i * i <= n:
    if n mod i == 0:
      result -= result div i
      while n mod i == 0: n = n div i
    i += 1
  if n > 1: result -= result div n
  return result
