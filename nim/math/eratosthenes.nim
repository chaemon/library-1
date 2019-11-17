#{{{ sieve_of_eratosthenes
type PrimeDivisors = object
  pdiv:seq[int]

proc eratosthenes(n:int):PrimeDivisors =
  var pdiv = newSeq[int](n + 1)
  for i in 2..n:
    pdiv[i] = i;
  for i in 2..n:
    if i * i > n: break
    if pdiv[i] == i:
      for j in countup(i*i,n,i):
        pdiv[j] = i;
  return PrimeDivisors(pdiv:pdiv)

proc isPrime(self:PrimeDivisors, n:int): bool =
  return n!=1 and self.pdiv[n] == n
#}}}
