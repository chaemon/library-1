# isPrime(x:int) {{{
proc isPrime(x:int):bool =
  if x == 1: return false
  var i = 2
  while i * i <= x:
    if x mod i == 0: return false
    i += 1
  return true
#}}}
