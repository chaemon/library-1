import sequtils

type Matrix[T] = seq[seq[T]]
type Vector[T] = seq[T]


proc `*`[T](self: Matrix[T], v: Matrix[T]): Matrix[T] =
  discard

proc `*`[T](self: Matrix[T], v: Vector[T]): Vector[T] =
  discard

var A = Matrix[int](newSeqWith(3, newSeqWith(3, 0)))

A = A * A
