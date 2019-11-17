proc isPrime(x:int):bool =
  var i = 2
  while i * i <= x:
    if x mod i == 0: return false
    i += 1
  return true
