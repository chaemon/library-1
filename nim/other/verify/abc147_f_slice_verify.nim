#{{{ header
{.hints:off checks:off.}
import algorithm, sequtils, tables, macros, math, sets, strutils
when defined(MYDEBUG):
  import header

proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc getchar(): char {.header: "<stdio.h>", varargs.}
proc nextInt(): int = scanf("%lld",addr result)
proc nextFloat(): float = scanf("%lf",addr result)
proc nextString(): string =
  var get = false
  result = ""
  while true:
    var c = getchar()
    if int(c) > int(' '):
      get = true
      result.add(c)
    else:
      if get: break
      get = false
type someSignedInt = int|int8|int16|int32|int64|BiggestInt
type someUnsignedInt = uint|uint8|uint16|uint32|uint64
type someInteger = someSignedInt|someUnsignedInt
type someFloat = float|float32|float64|BiggestFloat
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)
template inf(T): untyped = 
  when T is someFloat: T(Inf)
  elif T is someInteger: ((T(1) shl T(sizeof(T)*8-2)) - (T(1) shl T(sizeof(T)*4-1)))
  else: assert(false)

proc sort[T](v: var seq[T]) = v.sort(cmp[T])

proc discardableId[T](x: T): T {.discardable.} =
  return x
macro `:=`(x, y: untyped): untyped =
  if (x.kind == nnkIdent):
    return quote do:
      when declaredInScope(`x`):
        `x` = `y`
      else:
        var `x` = `y`
      discardableId(`x`)
  else:
    return quote do:
      `x` = `y`
      discardableId(`x`)
#}}}

#{{{ Slice
proc len[T](self: Slice[T]):int = (if self.a > self.b: 0 else: self.b - self.a + 1)
proc empty[T](self: Slice[T]):bool = self.len == 0

proc `<`[T](p, q: Slice[T]):bool = return if p.a < q.a: true elif p.a > q.a: false else: p.b < q.b
proc intersection[T](p, q: Slice[T]):Slice[T] = max(p.a, q.a)..min(p.b, q.b)
proc union[T](v: seq[Slice[T]]):seq[Slice[T]] =
  var v = v
  v.sort(cmp[Slice[T]])
  result = newSeq[Slice[T]]()
  var cur = -T.inf .. -T.inf
  for p in v:
    if p.empty: continue
    if cur.b + 1 < p.a:
      if cur.b != -T.inf: result.add(cur)
      cur = p
    elif cur.b < p.b: cur.b = p.b
  if cur.b != -T.inf: result.add(cur)
proc `in`[T](s:Slice[T], x:T):bool = s.contains(x)
proc `*`[T](p, q: Slice[T]):Slice[T] = intersection(p,q)
proc `+`[T](p, q: Slice[T]):seq[Slice[T]] = union(@[p,q])
#}}}

proc mod2(a, b:int):int =
  assert(b > 0)
  return ((a mod b) + b) mod b

proc countRange(v: seq[Slice[int]]):int =
  var v2 = v.union
  result = 0
  for p in v2: result += p.len

proc solve(N:int, X:var int, D:var int) =
  if D == 0:
    if X == 0:
      echo 1
    else:
      echo N + 1
    return
  if D < 0:
    X *= -1;D *= -1
  tb := initTable[int,seq[Slice[int]]]()
  # D > 0
  for k in 0..N:
    # use k term for Takahashi
    s := X * k
    t0 := (k * (0 + (k - 1))) div 2 # 0 + 1 + 2 + ... + (k - 1)
    t1 := (k * (N - 1 + (N - k))) div 2
    # add s + t0 * D, s + (t0 + 1) * D, ..., s + t1 * D
    # range: (t0, t1)
    r := mod2(s, D)
    if r notin tb: tb[r] = newSeq[Slice[int]]()
    u0 := (s + t0 * D - r) div D
    u1 := (s + t1 * D - r) div D
    tb[r].add(u0..u1)
  var ans = 0
  for r,v in tb:
    ans += countRange(v)
  echo ans
  return

#{{{ main function
proc main() =
  var N = 0
  N = nextInt()
  var X = 0
  X = nextInt()
  var D = 0
  D = nextInt()
  solve(N, X, D);
  return

main()
#}}}
