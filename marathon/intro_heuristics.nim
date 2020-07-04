#{{{ header
{.hints:off warnings:off optimization:speed.}
import algorithm, sequtils, tables, macros, math, sets, strutils, strformat, sugar
when defined(MYDEBUG):
  import header

import streams
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
#proc getchar(): char {.header: "<stdio.h>", varargs.}
proc nextInt(): int = scanf("%lld",addr result)
proc nextFloat(): float = scanf("%lf",addr result)
proc nextString[F](f:F): string =
  var get = false
  result = ""
  while true:
#    let c = getchar()
    let c = f.readChar
    if c.int > ' '.int:
      get = true
      result.add(c)
    elif get: return
proc nextInt[F](f:F): int = parseInt(f.nextString)
proc nextFloat[F](f:F): float = parseFloat(f.nextString)
proc nextString():string = stdin.nextString()

template `max=`*(x,y:typed):bool =
  if x < y: x = y;true
  else: false
template setmax*(x,y:typed):bool =
  if x < y: x = y;true
  else: false
template `min=`*(x,y:typed):bool =
  if x > y: x = y;true
  else: false
template inf(T): untyped = 
  when T is SomeFloat: T(Inf)
  elif T is SomeInteger: ((T(1) shl T(sizeof(T)*8-2)) - (T(1) shl T(sizeof(T)*4-1)))
  else: assert(false)

proc discardableId[T](x: T): T {.discardable.} =
  return x
macro `:=`(x, y: untyped): untyped =
  var strBody = ""
  if x.kind == nnkPar:
    for i,xi in x:
      strBody &= fmt"""
{xi.repr} := {y[i].repr}
"""
  else:
    strBody &= fmt"""
when declaredInScope({x.repr}):
  {x.repr} = {y.repr}
else:
  var {x.repr} = {y.repr}
"""
  strBody &= fmt"discardableId({x.repr})"
  parseStmt(strBody)


proc toStr[T](v:T):string =
  proc `$`[T](v:seq[T]):string =
    v.mapIt($it).join(" ")
  return $v

proc print0(x: varargs[string, toStr]; sep:string):string{.discardable.} =
  result = ""
  for i,v in x:
    if i != 0: addSep(result, sep = sep)
    add(result, v)
  result.add("\n")
  stdout.write result

var print:proc(x: varargs[string, toStr])
print = proc(x: varargs[string, toStr]) =
  discard print0(@x, sep = " ")

template makeSeq(x:int; init):auto =
  when init is typedesc: newSeq[init](x)
  else: newSeqWith(x, init)

macro Seq(lens: varargs[int]; init):untyped =
  var a = fmt"{init.repr}"
  for i in countdown(lens.len - 1, 0): a = fmt"makeSeq({lens[i].repr}, {a})"
  parseStmt(a)

template makeArray(x; init):auto =
  when init is typedesc:
    var v:array[x, init]
  else:
    var v:array[x, init.type]
    for a in v.mitems: a = init
  v

macro Array(lens: varargs[typed], init):untyped =
  var a = fmt"{init.repr}"
  for i in countdown(lens.len - 1, 0):
    a = fmt"makeArray({lens[i].repr}, {a})"
  parseStmt(a)
# }}}

import random, times

let start_time = epochTime()

randomize()

type Input = object
  D: int
  s: seq[seq[int]]
  c: seq[int]

proc compute_score(input: Input, output: seq[int]):int =
  var
    score = 0
    last = newSeq[int](26)
  for d in 0..<output.len:
    last[output[d]] = d + 1
    for i in 0..<26:
      score -= (d + 1 - last[i])  * input.c[i]
    score += input.s[d][output[d]]
  score

# TODO: 高速化
proc solve(input: var Input):seq[int] =
  var output = newSeq[int]()
  for _ in 0..<input.D:
    var
      max_score = -int.inf
      best_i = 0
    for i in 0..<26:
      output.add(i)
      let score = compute_score(input, output)
      if max_score < score:
        max_score = score
        best_i = i
      discard output.pop()
    output.add(best_i)
  output

type State = object
  output: seq[int]
  score:int
  ds:seq[seq[int]]

proc cost(a,b:int):int =
  let d = b - a
  d * (d - 1) div 2

proc initState(input: Input, output: seq[int]):State =
  var ds = newSeq[seq[int]](26)
  for d in 0..<input.D:
    ds[output[d]].add(d + 1)
  let score = compute_score(input, output)
  return State(output:output, score:score, ds:ds)

proc change(self: var State, input:Input, d, new_i:int) =
  proc get_or(a:seq[int], p:int, v:int):int =
    if p in 0..<a.len: return a[p]
    else: return v
  let old_i = self.output[d]
  block:
    let
      p = self.ds[old_i].find(d + 1)
      prev = self.ds[old_i].get_or(p - 1, 0)
      next = self.ds[old_i].get_or(p + 1, input.D + 1)
    self.ds[old_i].delete(p)
    self.score += (cost(prev, d + 1) + cost(d + 1, next) - cost(prev, next)) * input.c[old_i]
  block:
    let
      p = self.ds[new_i].upper_bound(d + 1)
      prev = self.ds[new_i].get_or(p - 1, 0)
      next = self.ds[new_i].get_or(p, input.D + 1)
    self.ds[new_i].insert(p, d + 1)
    self.score -= (cost(prev, d + 1) + cost(d + 1, next) - cost(prev, next)) * input.c[new_i]
    self.score += input.s[d][new_i] - input.s[d][old_i]
  self.output[d] = new_i

proc solveAnnealing(input: var Input):seq[int] =
  const
    T0 = 2000.0
    T1 = 600.0
    TL = 1.9
  var
    state = initState(input, newSeqWith(input.D, rand(0..<26)))
    T = T0
    best = state.score
    best_out = state.output
    cnt = 0
  while true:
    cnt += 1
    if cnt mod 100 == 0:
      let t = (epochTime() - start_time) / TL
      if t >= 1.0: break
      T = T0.pow(1.0 - t) * T1.pow(t)
    let old_score = state.score
    if rand(1.0) <= 0.5:
      let
        d = rand(0..<input.D)
        old = state.output[d]
      state.change(input, d, rand(0..<26))
      if old_score > state.score and rand(1.0) > exp((state.score - old_score).float/T):
        state.change(input, d, old)
    else:
      let
        d1 = rand(0..<input.D - 1)
        d2 = rand(d1 + 1..<(d1 + 16).min(input.D))
        (a, b) = (state.output[d1], state.output[d2])
      state.change(input, d1, b)
      state.change(input, d2, a)
    if best < state.score:
      best = state.score
      best_out = state.output
  best_out
