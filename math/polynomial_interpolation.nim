# polynomialInterpolation(xs, ys) f(xs[i]) = ys[i] {{{
proc polynomialInterpolation[T](xs: FormalPowerSeries[T], ys:seq[T]): FormalPowerSeries[T] =
  doAssert(xs.data.len == ys.len)
  var buf = initPolyBuf[T](xs)
  let
    w = buf.query(0, xs.data.len).diff()
    vs = multipointEvaluation(w, xs, buf)
  proc rec(l, r:int):auto =
    if r - l == 1: return initFormalPowerSeries(@[ys[l] / vs[l]])
    let m = (l + r) shr 1
    return rec(l, m) * buf.query(m, r) + rec(m, r) * buf.query(l, m)
  return rec(0, xs.data.len)
# }}}
