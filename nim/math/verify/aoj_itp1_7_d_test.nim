#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=ITP1_7_D"

include "../../template/template.nim"

include "../matrix.nim"

proc main() =
  let n, m, l = nextInt()
  var
    a = initMatrix[int](n, m)
    b = initMatrix[int](m, l)
  for i in 0..<n:
    for j in 0..<m:
      a[i][j] = nextInt()
  for i in 0..<m:
    for j in 0..<l:
      b[i][j] = nextInt()
  var c = a * b
  for i in 0..<n:
    for j in 0..<l:
      stdout.write c[i][j]
      if j + 1 < l: stdout.write " "
    echo ""

main()
