#{{{ bitutils
proc bits(v:varargs[int]): uint64 =
  result = 0
  for x in v: result = (result or (1'u64 shl uint64(x)))
proc `[]`(b:uint64,n:int):int =
  if (b and (1'u64 shl uint64(n))) == 0: 0 else: 1
proc test(b:uint64,n:int):bool =
  if b[n] == 1:true else: false
proc set(b:var uint64,n:int) = b = (b or (1'u64 shl uint64(n)))
proc unset(b:var uint64,n:int) = b = (b and (not (1'u64 shl uint64(n))))
proc `[]=`(b:var uint64,n:int,t:int) =
  if t == 0: b.unset(n)
  elif t == 1: b.set(n)
  else: assert(false)
proc writeBits(b:uint64,n:int = 64) =
  for i in countdown(n-1,0):stdout.write(b[i])
  echo ""
proc setBits(n:int):uint64 =
  if n == 64: (not 0'u64)
  else: (1'u64 shl uint64(n)) - 1'u64
#}}}
