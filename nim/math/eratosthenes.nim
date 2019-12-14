#{{{ sieve_of_eratosthenes
type Eratosthenes = object
  pdiv:seq[int]

proc initEratosthenes(n:int):Eratosthenes =
  var pdiv = newSeq[int](n + 1)
  for i in 2..n:
    pdiv[i] = i;
  for i in 2..n:
    if i * i > n: break
    if pdiv[i] == i:
      for j in countup(i*i,n,i):
        pdiv[j] = i;
  return Eratosthenes(pdiv:pdiv)

proc isPrime(self:Eratosthenes, n:int): bool =
  return n != 1 and self.pdiv[n] == n
#}}}
