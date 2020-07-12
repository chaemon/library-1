# multipointEvaluation[T](cs, xs: FormalPowerSeries[T]) {{{
import tables

type PolyBuf[T] = object
  xs:FormalPowerSeries[T]
  buf: Table[(int,int), FormalPowerSeries[T]]

proc initPolyBuf[T](xs:FormalPowerSeries[T]):PolyBuf[T] = PolyBuf[T](xs:xs, buf:initTable[(int,int), FormalPowerSeries[T]]())

proc query[T](self: var PolyBuf[T], l,r:int):FormalPowerSeries[T] =
  if (l,r) in self.buf: return self.buf[(l,r)]
  if l + 1 == r:
    self.buf[(l, r)] = initFormalPowerSeries[T](@[-self.xs[l], T(1)])
  else:
    self.buf[(l, r)] = self.query(l, (l + r) shr 1) * self.query((l + r) shr 1, r)
  return self.buf[(l,r)]

proc multipointEvaluation[T](cs, xs:FormalPowerSeries[T], buf: var PolyBuf[T]):FormalPowerSeries[T] =
  var ret = initFormalPowerSeries[T](0)
  const B = 64
  proc rec(a:FormalPowerSeries[T], l, r:int, buf: var PolyBuf[T]) =
    var a = a
    a.`mod=` buf.query(l, r)
    if a.len <= B:
      for i in l..<r: ret.add(a.eval(xs[i]))
      return
    rec(a, l, (l + r) shr 1, buf)
    rec(a, (l + r) shr 1, r, buf)
  rec(cs, 0, xs.len, buf)
  return ret

proc multipointEvaluation[T](cs, xs: FormalPowerSeries[T]):FormalPowerSeries[T] =
  var buff = initPolyBuf[T](xs)
  return multipoint_evaluation(cs, xs, buff)
# }}}
