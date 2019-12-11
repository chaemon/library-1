#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=ITP1_6_D"

include "../../template/template.nim"

include "../matrix.nim"

proc main() =
  let n, m = nextInt()
  var a = initMatrix[int](n, m)
  for i in 0..<n:
    for j in 0..<m:
      a[i][j] = nextInt()
  var b = initVector[int](m)
  for j in 0..<m:
    b[j] = nextInt()
  var c = a * b
  for ci in c: echo ci

main()
